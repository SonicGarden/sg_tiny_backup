# frozen_string_literal: true

module TestCommandHelper
  module_function

  def test_command
    script = File.expand_path("../test_commands/test.rb", __dir__)
    "ruby #{script}"
  end

  def build_command_instance(command_str, success_codes: [0])
    k = Class.new(SgTinyBackup::Commands::Base)
    command = command_str.dup
    k.define_method :command do
      command
    end
    codes = success_codes.dup
    k.define_method :success_codes do
      codes
    end
    k.new
  end

  def build_test_command_instance(args_str, success_codes: [0])
    TestCommandHelper.build_command_instance("#{TestCommandHelper.test_command} #{args_str}", success_codes: success_codes)
  end
end

RSpec.configure do |config|
  config.include TestCommandHelper
end
