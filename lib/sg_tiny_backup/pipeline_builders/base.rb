# frozen_string_literal: true

require_relative "s3"

module SgTinyBackup
  module PipelineBuilders
    class Base
      attr_reader :s3_config

      def initialize(config:, basename:, local:, s3_config:, extension:)
        @config = config
        @basename = basename
        @local = local
        @s3_config = s3_config
        @extension = extension
      end

      def base_filename
        "#{@basename}.#{@extension}"
      end

      def destination_url
        S3.build_s3_url(s3_config: s3_config, base_filename: base_filename)
      end

      def local?
        @local
      end

      private

      def aws_cli_command
        S3.build_aws_cli_command(s3_config: s3_config, destination_url: destination_url)
      end
    end
  end
end
