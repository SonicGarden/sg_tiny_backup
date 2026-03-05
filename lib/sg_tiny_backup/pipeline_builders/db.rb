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
          extension: config.compression["method"] == "zstd" ? "sql.zst.enc" : "sql.gz.enc"
        )
      end

      def build
        output_path = base_filename if local?
        pl = Pipeline.new(output_path: output_path)
        pl << db_dump_command
        pl << compression_command
        pl << Commands::Openssl.new(password: @config.encryption_key)
        pl << aws_cli_command unless local?
        pl
      end

      private

      def compression_command
        level = @config.compression["level"]
        case @config.compression["method"]
        when "zstd"
          Commands::Zstd.new(level: level)
        else
          Commands::Gzip.new(level: level)
        end
      end

      def db_dump_command
        db_config = @config.db
        adapter = db_config["adapter"]
        raise "database adapter is not specified in your config." if adapter.nil?

        case adapter
        when "postgresql"
          pg_dump_command(db_config)
        when "mysql2"
          mysql_dump_command(db_config)
        else
          raise "database adapter `#{adapter}` is not supported."
        end
      end

      def pg_dump_command(db_config)
        Commands::PgDump.new(
          database: db_config["database"],
          host: db_config["host"],
          port: db_config["port"],
          user: db_config["username"] || db_config["user"],
          password: db_config["password"],
          extra_options: @config.pg_dump["extra_options"]
        )
      end

      def mysql_dump_command(db_config)
        Commands::MysqlDump.new(
          database: db_config["database"],
          host: db_config["host"],
          port: db_config["port"],
          user: db_config["username"] || db_config["user"],
          password: db_config["password"],
          extra_options: @config.mysqldump["extra_options"]
        )
      end
    end
  end
end
