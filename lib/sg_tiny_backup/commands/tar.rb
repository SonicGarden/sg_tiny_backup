# frozen_string_literal: true

require "shellwords"
require "open3"
require_relative "base"

module SgTinyBackup
  module Commands
    class Tar < Base
      def initialize(paths: [])
        super()
        @paths = paths
        check_missing_paths
      end

      def command
        if existing_paths.empty?
          # Create empty tar archive.
          "tar -c -T /dev/null"
        else
          cmd = ["tar -c"]
          existing_paths.map do |path|
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

      def strong_warning_message
        unless @missing_paths.empty?
          "tar: missing files: #{@missing_paths.join(", ")}"
        end
      end

      private

      def check_missing_paths
        @missing_paths = @paths.reject { |path| File.file?(path) || File.directory?(path) }
      end

      def existing_paths
        @existing_paths ||= @paths - @missing_paths
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
