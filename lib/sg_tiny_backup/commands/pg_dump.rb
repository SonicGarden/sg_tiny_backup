# frozen_string_literal: true

module SgTinyBackup
  module Commands
    class PgDump
      attr_reader :user, :host, :port, :password, :database

      def initialize(database:, user: nil, host: nil, port: nil, password: nil)
        @user = user
        @host = host
        @port = port
        @password = password
        @database = database
      end

      def command
        parts = []
        parts << "PGPASSWORD=#{Shellwords.escape(@password)}" if @password
        parts << "pg_dump"
        parts << "--username=#{Shellwords.escape(@user)}" if @user
        parts << "--host=#{@host}" if @host
        parts << "--port=#{@port}" if @port
        parts << @database
        parts.join(" ")
      end
    end
  end
end
