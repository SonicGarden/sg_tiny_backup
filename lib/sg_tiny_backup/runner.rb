# frozen_string_literal: true

require_relative "commands/aws_cli"
require_relative "commands/gzip"
require_relative "commands/pg_dump"
require_relative "commands/openssl"
require_relative "pipeline"
require_relative "error"

module SgTinyBackup
  class Runner
    def initialize(config:, basename:, local: false)
      @config = config
      @basename = basename
      @local = local
    end

    def run
      pipeline.run
      output_warning(pipeline.warning_messages)
      output_error(pipeline.error_messages) if pipeline.failed?
      pipeline.succeeded?
    end

    def plain_commands
      pipeline.plain_commands
    end

    def piped_command
      plain_commands.join(" | ")
    end

    def env
      pipeline.env
    end

    def s3_destination_url
      s3_config = @config.s3
      object_path = [s3_config["prefix"], base_filename].join
      "s3://#{File.join(s3_config["bucket"], object_path)}"
    end

    def base_filename
      "#{@basename}.sql.gz.enc"
    end

    private

    def pipeline
      @pipeline ||= begin
        pl = Pipeline.new
        pl << pg_dump_command
        pl << Commands::Gzip.new
        if @local
          pl << Commands::Openssl.new(password: @config.encryption_key, filename: base_filename)
        else
          pl << Commands::Openssl.new(password: @config.encryption_key)
          pl << aws_cli_command
        end
        pl
      end
    end

    def output_warning(message)
      return if message.empty?

      SgTinyBackup.logger.warn message
    end

    def output_error(message)
      SgTinyBackup.logger.error message
      raise BackupFailed, message if SgTinyBackup.raise_on_error
    end

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

    def aws_cli_command
      s3_config = @config.s3
      expected_size = s3_config["expected_upload_size"].to_i if s3_config["expected_upload_size"]
      Commands::AwsCli.new(
        destination_url: s3_destination_url,
        access_key_id: s3_config["access_key_id"],
        secret_access_key: s3_config["secret_access_key"],
        expected_size: expected_size
      )
    end
  end
end
