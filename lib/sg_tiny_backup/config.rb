# frozen_string_literal: true

require "yaml"
require "erb"
require "fileutils"

module SgTinyBackup
  class Config
    KEY_PG_DUMP = "pg_dump"
    KEY_MYSQLDUMP = "mysqldump"
    KEY_S3 = "s3"
    KEY_DB = "db"
    KEY_ENCRYPTION_KEY = "encryption_key"
    KEY_EXPECTED_UPLOAD_SIZE = "expected_upload_size"
    KEY_LOG = "log"
    KEY_FILES = "files"
    KEY_OPTIONAL_FILES = "optional_files"

    attr_reader :s3, :encryption_key, :pg_dump, :mysqldump, :db

    def initialize(s3:, encryption_key:, pg_dump: nil, mysqldump: nil, db: nil, log: nil) # rubocop:disable Metrics/ParameterLists
      @s3 = s3
      @encryption_key = encryption_key
      @pg_dump = pg_dump || {}
      @mysqldump = mysqldump
      @db = db || self.class.rails_db_config
      @log = log || {}
    end

    def log_file_paths
      @log[KEY_FILES] || []
    end

    def optional_log_file_paths
      @log[KEY_OPTIONAL_FILES] || []
    end

    class << self
      def resolve_erb(value)
        case value
        when Hash
          value.transform_values do |v|
            resolve_erb(v)
          end
        when Array
          value.map { |v| resolve_erb(v) }
        when String
          ERB.new(value).result
        else
          value
        end
      end

      def read(io)
        yaml = YAML.safe_load(io, permitted_classes: [], permitted_symbols: [], aliases: true)
        yaml = resolve_erb(yaml)
        Config.new(
          s3: yaml[KEY_S3],
          encryption_key: yaml[KEY_ENCRYPTION_KEY],
          db: yaml[KEY_DB],
          pg_dump: yaml[KEY_PG_DUMP],
          mysqldump: yaml[KEY_MYSQLDUMP],
          log: yaml[KEY_LOG]
        )
      end

      def read_file(path)
        File.open(path, "r") do |f|
          read(f)
        end
      end

      def generate_template_file(path)
        template_path = File.expand_path("./templates/sg_tiny_backup.yml", __dir__)
        FileUtils.cp(template_path, path)
      end

      def rails_db_config
        return unless defined?(Rails)

        db_config = File.open(Rails.root.join("config", "database.yml"), "r") do |f|
          YAML.safe_load(f, permitted_classes: [], permitted_symbols: [], aliases: true)
        end
        db_config = resolve_erb(db_config)
        db_config[Rails.env]
      end
    end
  end
end
