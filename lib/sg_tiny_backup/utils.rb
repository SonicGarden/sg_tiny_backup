# frozen_string_literal: true

require "socket"

module SgTinyBackup
  module Utils
    class << self
      def timestamp
        Time.now.strftime("%Y%m%d_%H%M%S")
      end

      def basename(target)
        if target == "log"
          "#{Socket.gethostname}_#{timestamp}"
        else
          timestamp
        end
      end
    end
  end
end
