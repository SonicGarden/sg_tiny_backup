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

    def error_message
      [@spawner.stderr_message, @spawner.exit_code_error_message].join
    end

    def warning_message
      messages = [commands_warning_message]
      messages << @spawner.stderr_message if succeeded? && !@spawner.stderr_message.empty?
      messages.reject { |str| str.nil? || str.empty? }.join("\n")
    end

    private

    def commands_warning_message
      @commands.filter_map(&:warning_message).join("\n")
    end

    def build_spawner
      Spawner.new(commands: @commands, env: env, output_path: @output_path)
    end
  end
end
