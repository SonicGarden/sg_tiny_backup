# frozen_string_literal: true

require "sg_tiny_backup/commands"
require "sg_tiny_backup/pipeline"
require_relative "base"

module SgTinyBackup
  module PipelineBuilders
    class Log < Base
      def initialize(config:, basename:, local:)
        super(
          config: config,
          basename: basename,
          local: local,
          s3_config: config.s3["log"],
          extension: "tar.gz"
        )
      end

      def build
        output_path = base_filename if local?
        pl = Pipeline.new(output_path: output_path)
        pl << Commands::Tar.new(paths: @config.log_file_paths)
        pl << Commands::Gzip.new
        pl << aws_cli_command unless local?
        pl
      end

      private

      def extension
        "tar.gz"
      end
    end
  end
end
