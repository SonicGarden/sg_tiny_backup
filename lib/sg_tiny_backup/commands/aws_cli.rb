# frozen_string_literal: true

module SgTinyBackup
  module Commands
    class AwsCli
      def initialize(destination_url:, access_key_id:, secret_access_key:, expected_size: nil)
        @destination_url = destination_url
        @access_key_id = access_key_id
        @secret_access_key = secret_access_key
        @expected_size = expected_size
      end

      def command
        parts = []
        parts << "AWS_ACCESS_KEY_ID=#{@access_key_id} AWS_SECRET_ACCESS_KEY=#{@secret_access_key}"
        parts << "aws s3 cp"
        parts << "--expected-size #{@expected_size}" if @expected_size
        parts << "- #{@destination_url}"
        parts.join(" ")
      end
    end
  end
end
