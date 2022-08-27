# frozen_string_literal: true

require_relative "base"

module SgTinyBackup
  module Commands
    class Gzip < Base
      def initialize(level: nil)
        super()
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
