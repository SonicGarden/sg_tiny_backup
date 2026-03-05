# frozen_string_literal: true

require_relative "base"

module SgTinyBackup
  module Commands
    class Zstd < Base
      def initialize(level: nil)
        super()
        @level = level
      end

      def command
        parts = ["zstd -c"]
        parts << "--ultra" if @level && @level >= 20
        parts << "-#{@level}" if @level
        parts.join(" ")
      end
    end
  end
end
