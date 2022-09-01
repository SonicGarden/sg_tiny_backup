# frozen_string_literal: true

require "shellwords"
require "sg_tiny_backup/error"

module SgTinyBackup
  class Pipeline
    attr_reader :stdout, :stderr, :exit_code_errors

    def initialize(output_path: nil)
      @commands = []
      @exit_code_errors = []
      @output_path = output_path
    end

    def <<(command)
      @commands << command
      self
    end

    def run
      spawn_and_wait
    end

    def plain_commands
      @commands.map(&:command)
    end

    def env
      @commands.map(&:env).reduce({}, &:merge)
    end

    def succeeded?
      @exit_code_errors.empty?
    end

    def failed?
      !succeeded?
    end

    def error_messages
      [stderr_messages, exit_code_error_messages].join
    end

    def warning_messages
      if succeeded? && !stderr_messages.empty?
        stderr_messages
      else
        ""
      end
    end

    private

    def stderr_messages
      @stderr_messages ||=
        if @stderr.empty?
          ""
        else
          <<~END_OF_MESSAGE
            STDERR messages:

            #{@stderr}
          END_OF_MESSAGE
        end
    end

    def exit_code_error_messages
      if succeeded?
        ""
      else
        <<~END_OF_MESSAGE
          The following errors were returned:

          #{@exit_code_errors.join("\n")}
        END_OF_MESSAGE
      end
    end

    def spawn_and_wait
      spawn_pipeline_command do |pid, out_r, err_r, status_r|
        @stdout = out_r.read
        @stderr = err_r.read
        pipe_status_str = status_r.read
        Process.wait(pid)
        parse_pipe_status(pipe_status_str)
      end
    rescue StandardError => e
      raise SpawnError.new("Pipeline failed to execute", e)
    end

    def spawn_pipeline_command # rubocop:disable Metrics/AbcSize
      opts = {}
      out_r, out_w = IO.pipe
      opts[:out] = out_w

      err_r, err_w = IO.pipe
      opts[:err] = err_w

      status_r, status_w = IO.pipe
      opts[3] = status_w

      pid = spawn(env, pipeline_command, opts)
      out_w.close
      err_w.close
      status_w.close

      yield pid, out_r, err_r, status_r
    end

    def parse_pipe_status(pipe_status_str)
      @exit_code_errors = []
      pipe_statuses = pipe_status_str.delete("\n").split(":").sort
      pipe_statuses.each do |status|
        index, exit_code = status.split("|").map(&:to_i)
        command = @commands[index]
        next if command.success_codes.member?(exit_code)

        @exit_code_errors << "`#{command.command}` returned exit code: #{exit_code}"
      end
    end

    def pipeline_command
      parts = []
      @commands.each_with_index do |command, index|
        parts << %({ #{command.command} ; echo "#{index}|$?:" >&3 ; })
      end
      command = parts.join(" | ")
      command += "> #{Shellwords.escape(@output_path)}" if @output_path
      command
    end
  end
end
