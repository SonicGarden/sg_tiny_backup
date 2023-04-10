# frozen_string_literal: true

require "logger"
require "sg_tiny_backup/config"
require "sg_tiny_backup/runner"
require "sg_tiny_backup/utils"
require "sg_tiny_backup/version"
require "sg_tiny_backup/railtie" if defined?(Rails)

module SgTinyBackup
  class << self
    attr_accessor :error_handler
    attr_writer :logger
    attr_reader :raise_on_error

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def raise_on_error=(value)
      ActiveSupport::Deprecation.warn("Use SgTinyBackup.error_handler")
      @raise_on_error = value
      SgTinyBackup.error_handler = value ? ->(error) { raise error } : nil
    end
  end
end

SgTinyBackup.error_handler = ->(error) { raise error }
