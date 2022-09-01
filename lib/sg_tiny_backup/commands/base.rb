# frozen_string_literal: true

module SgTinyBackup
  module Commands
    class Base
      def command
        raise NotImplementedError
      end

      def env
        {}
      end

      def success_codes
        [0]
      end
    end
  end
end
