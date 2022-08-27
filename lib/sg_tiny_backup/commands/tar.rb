# frozen_string_literal: true

require "shellwords"
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
    end
  end
end
