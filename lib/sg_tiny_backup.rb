# frozen_string_literal: true

require_relative "sg_tiny_backup/config"
require_relative "sg_tiny_backup/runner"
require_relative "sg_tiny_backup/version"
require_relative "sg_tiny_backup/railtie" if defined?(Rails)

module SgTinyBackup
end
