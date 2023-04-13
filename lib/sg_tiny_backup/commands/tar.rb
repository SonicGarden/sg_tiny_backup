# frozen_string_literal: true

require "shellwords"
require "open3"
require_relative "base"

module SgTinyBackup
  module Commands
    class Tar < Base
      def initialize(paths: [], optional_paths: [])
        super()
        @paths = paths
        @optional_paths = optional_paths
      end

      def command
        if target_file_paths.empty?
          # Create empty tar archive.
          "tar -c -T /dev/null"
        else
          cmd = ["tar -c"]
          target_file_paths.map do |path|
            cmd << Shellwords.escape(path)
          end
          cmd.join(" ")
        end
      end

      def success_codes
        if self.class.gnu_tar?
          # GNU tar's exit code 1 means that some files were changed while being archived.
          # See https://www.gnu.org/software/tar/manual/html_section/Synopsis.html
          [0, 1]
        else
          [0]
        end
      end

      def warning_message
        "tar: missing files: #{missing_optinal_file_paths.join(", ")}" unless missing_optinal_file_paths.empty?
      end

      private

      def existing_optional_file_paths
        @existing_optional_file_paths ||= @optional_paths.select { |path| File.file?(path) || File.directory?(path) }
      end

      def missing_optinal_file_paths
        @missing_optinal_file_paths ||= @optional_paths - existing_optional_file_paths
      end

      def target_file_paths
        @target_file_paths ||= @paths + existing_optional_file_paths
      end

      class << self
        def gnu_tar?
          unless defined?(@gnu_tar)
            out, _err, status = Open3.capture3("tar --version")
            @gnu_tar = status.success? && out.match?(/GNU/)
          end
          @gnu_tar
        end
      end
    end
  end
end
