# frozen_string_literal: true

require "yaml"
require "erb"
require "fileutils"

module SgTinyBackup
  class Config
    KEY_PG_DUMP = "pg_dump"
    KEY_S3 = "s3"
    KEY_DB = "db"
    KEY_ENCRYPTION_KEY = "encryption_key"
    KEY_EXPECTED_UPLOAD_SIZE = "expected_upload_size"

    attr_reader :s3, :encryption_key, :pg_dump, :db

    def initialize(s3:, encryption_key:, pg_dump: nil, db: nil)
      @s3 = s3
      @encryption_key = encryption_key
      @pg_dump = pg_dump || {}
      @db = db || self.class.rails_db_config
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
          pg_dump: yaml[KEY_PG_DUMP]
        )
      end

      def read_file(path)
        File.open(path, "r") do |f|
          read(f)
        end
      end

      def write_template(io)
        template = File.read(template_path)
        template.gsub!("${ENCRYPTION_KEY}", SecureRandom.hex(64))
        io.write(template)
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
        db_config[Rails.env]
      end
    end
  end
end
