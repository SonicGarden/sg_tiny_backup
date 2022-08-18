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
    end
  end
end
