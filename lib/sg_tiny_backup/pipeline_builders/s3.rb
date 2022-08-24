# frozen_string_literal: true

require "sg_tiny_backup/commands/aws_cli"

module SgTinyBackup
  module PipelineBuilders
    module S3
      class << self
        def build_aws_cli_command(s3_config:, destination_url:)
          expected_size = s3_config["expected_upload_size"].to_i if s3_config["expected_upload_size"]
          Commands::AwsCli.new(
            destination_url: destination_url,
            access_key_id: s3_config["access_key_id"],
            secret_access_key: s3_config["secret_access_key"],
            expected_size: expected_size
          )
        end

        def build_s3_url(s3_config:, base_filename:)
          object_path = [s3_config["prefix"], base_filename].join
          "s3://#{File.join(s3_config["bucket"], object_path)}"
        end
      end
    end
  end
end
