# frozen_string_literal: true

require_relative "commands/aws_cli"
require_relative "commands/gzip"
require_relative "commands/pg_dump"
require_relative "commands/openssl"

module SgTinyBackup
  class Runner
    def initialize(config:, basename:)
      @config = config
      @basename = basename
    end

    def run
      # TODO: Read stderr and build detailed error.
      system(env, command, exception: true)
    end

    def command
      commands.map(&:command).join(" | ")
    end

    def env
      commands.map(&:env).reduce(&:merge)
    end

    def s3_destination_url
      s3_config = @config.s3
      object_path = [s3_config["prefix"], "#{@basename}.sql.gz.enc"].join
      "s3://#{File.join(s3_config["bucket"], object_path)}"
    end

    private

    def commands
      @commands ||= begin
        command_array = []
        command_array << pg_dump_command
        command_array << Commands::Gzip.new
        command_array << Commands::Openssl.new(password: @config.encryption_key)
        command_array << aws_cli_command
      end
    end

    def pg_dump_command
      db_config = @config.db
      Commands::PgDump.new(
        database: db_config["database"],
        user: db_config["user"],
        host: db_config["host"],
        port: db_config["port"],
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