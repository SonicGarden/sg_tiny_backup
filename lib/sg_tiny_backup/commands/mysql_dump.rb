# frozen_string_literal: true

require_relative "base"

module SgTinyBackup
  module Commands
    class MysqlDump < Base
      attr_reader :user, :host, :port, :password, :database, :extra_options

      def initialize(database:, host: nil, port: nil, user: nil, password: nil, extra_options: nil) # rubocop:disable Metrics/ParameterLists
        super()
        @user = user
        @host = host
        @port = port
        @password = password
        @database = database
        @extra_options = extra_options
      end

      def command
        parts = []
        parts << "mysqldump"
        parts << extra_options if extra_options
        parts << "--user=#{Shellwords.escape(@user)}" if @user
        parts << "--host=#{@host}" if @host
        parts << "--port=#{@port}" if @port
        parts << @database
        parts.join(" ")
      end

      def env
        {
          "MYSQL_PWD" => @password,
        }.compact
      end
    end
  end
end
