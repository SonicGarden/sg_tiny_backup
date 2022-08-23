# frozen_string_literal: true

require "logger"
require_relative "sg_tiny_backup/config"
require_relative "sg_tiny_backup/runner"
require_relative "sg_tiny_backup/version"
require_relative "sg_tiny_backup/railtie" if defined?(Rails)

module SgTinyBackup
  class << self
    attr_accessor :raise_on_error
    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
