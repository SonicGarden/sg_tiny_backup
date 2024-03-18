# frozen_string_literal: true

require "socket"
require "yaml"
require "erb"

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

      def load_yaml_with_erb(io)
        yaml_content = io.read
        resolved = ERB.new(yaml_content).result
        YAML.safe_load(
          resolved,
          permitted_classes: [],
          permitted_symbols: [],
          aliases: true
        )
      end
    end
  end
end
