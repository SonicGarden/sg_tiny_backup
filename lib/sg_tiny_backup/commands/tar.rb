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
      end

      def command
        cmd = ["tar -c"]
        @paths.map do |path|
          cmd << Shellwords.escape(path)
        end
        cmd.join(" ")
      end

      def success_codes
        if self.class.gnu_tar?
          # GNU tar's exit code 1 means that some files were changed while being archived.
          [0, 1].freeze
        else
          [0].freeze
        end
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
