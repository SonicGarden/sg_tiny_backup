# frozen_string_literal: true

require "sg_tiny_backup/commands"
require "sg_tiny_backup/pipeline"
require_relative "base"

module SgTinyBackup
  module PipelineBuilders
    class Db < Base
      def initialize(config:, basename:, local:)
        super(
          config: config,
          basename: basename,
          local: local,
          s3_config: config.s3["db"],
          extension: "sql.gz.enc"
        )
      end

      def build
        output_path = base_filename if local?
        pl = Pipeline.new(output_path: output_path)
        pl << pg_dump_command
        pl << Commands::Gzip.new
        pl << Commands::Openssl.new(password: @config.encryption_key)
        pl << aws_cli_command unless local?
        pl
      end

      private

      def pg_dump_command
        db_config = @config.db
        Commands::PgDump.new(
          database: db_config["database"],
          host: db_config["host"],
          port: db_config["port"],
          user: db_config["username"] || db_config["user"],
          password: db_config["password"],
          extra_options: @config.pg_dump["extra_options"]
        )
      end
    end
  end
end
