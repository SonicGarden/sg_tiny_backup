# frozen_string_literal: true

require_relative "./base"

module SgTinyBackup
  module Commands
    class Openssl < Base
      CIPHER = "aes-256-cbc"
      ITER = 10_000

      def initialize(password:)
        super()
        @password = password
      end

      def command
        parts = ["openssl enc -#{CIPHER} -pbkdf2 -iter #{ITER}"]
        parts << "-pass env:SG_TINY_BACKUP_ENCRYPTION_KEY"
        parts.join(" ")
      end

      def env
        {
          "SG_TINY_BACKUP_ENCRYPTION_KEY" => @password,
        }
      end

      class << self
        def decryption_command
          parts = ["openssl enc -d -#{CIPHER} -pbkdf2 -iter #{ITER}"]
          parts << "-pass pass:ENCRYPTION_KEY"
          parts << "-in INPUTFILE -out OUTPUTFILE"
          parts.join(" ")
        end
      end
    end
  end
end
