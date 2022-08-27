# frozen_string_literal: true

require "logger"
require "sg_tiny_backup/config"
require "sg_tiny_backup/runner"
require "sg_tiny_backup/utils"
require "sg_tiny_backup/version"
require "sg_tiny_backup/railtie" if defined?(Rails)

module SgTinyBackup
  class << self
    attr_accessor :raise_on_error
    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
