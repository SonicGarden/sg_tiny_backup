# frozen_string_literal: true

module SgTinyBackup
  module Utils
    class << self
      def timestamp
        Time.now.strftime("%Y%m%d_%H%M%S")
      end
    end
  end
end
