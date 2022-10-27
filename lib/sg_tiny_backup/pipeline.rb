# frozen_string_literal: true

require "forwardable"
require "sg_tiny_backup/spawner"

module SgTinyBackup
  class Pipeline
    extend Forwardable

    delegate stdout: :@spawner
    delegate stderr: :@spawner
    delegate succeeded?: :@spawner

    def initialize(output_path: nil)
      @commands = []
      @spawner = build_spawner
      @output_path = output_path
    end

    def <<(command)
      @commands << command
      self
    end

    def run
      @spawner = build_spawner
      @spawner.spawn_and_wait
    end

    def plain_commands
      @commands.map(&:command)
    end

    def env
      @commands.map(&:env).reduce({}, &:merge)
    end

    def failed?
      !succeeded?
    end

    def error_messages
      [@spawner.stderr_messages, @spawner.exit_code_error_messages].join
    end

    def strong_warning_messages
      @commands.filter_map(&:strong_warning_message).join("\n")
    end

    def warning_messages
      if succeeded? && !@spawner.stderr_messages.empty?
        @spawner.stderr_messages
      else
        ""
      end
    end

    private

    def build_spawner
      Spawner.new(commands: @commands, env: env, output_path: @output_path)
    end
  end
end
