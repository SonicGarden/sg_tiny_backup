# frozen_string_literal: true

require "sg_tiny_backup/pipeline"
require "sg_tiny_backup/error"
require "sg_tiny_backup/pipeline_builders/db"
require "sg_tiny_backup/pipeline_builders/log"

module SgTinyBackup
  class Runner
    attr_reader :target

    TARGET_DB = "db"
    TARGET_LOG = "log"

    def initialize(config:, basename:, target: "db", local: false, pipeline_builder: nil)
      @config = config
      @basename = basename
      @target = target
      @local = local
      @pipeline_builder = pipeline_builder
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
      pipeline_builder.destination_url
    end

    def base_filename
      pipeline_builder.base_filename
    end

    private

    def pipeline
      @pipeline ||= pipeline_builder.build
    end

    def pipeline_builder
      @pipeline_builder ||=
        case target
        when TARGET_DB
          SgTinyBackup::PipelineBuilders::Db.new(config: @config, basename: @basename, local: @local)
        when TARGET_LOG
          SgTinyBackup::PipelineBuilders::Log.new(config: @config, basename: @basename, local: @local)
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
  end
end
