# frozen_string_literal: true

module SgTinyBackup
  module Commands
    class Gzip
      def initialize(level: nil)
        @level = level
      end

      def command
        parts = ["gzip"]
        parts = "-#{@level}" if @level
        parts.join(" ")
      end
    end
  end
end
