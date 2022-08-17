# frozen_string_literal: true

module SgTinyBackup
  module Commands
    class Openssl
      CIPHER = "aes-256-cbc"
      ITER = 10_000

      def initialize(password:)
        @password = password
      end

      def command
        parts = ["openssl enc -#{CIPHER} -pbkdf2 -iter #{ITER}"]
        parts << "-pass pass:#{@password}"
        parts.join(" ")
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
