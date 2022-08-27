# frozen_string_literal: true

module TestCommandHelper
  module_function

  def test_command
    script = File.expand_path("../test_commands/test.rb", __dir__)
    "ruby #{script}"
  end

  def build_command_instance(command_str)
    k = Class.new(SgTinyBackup::Commands::Base)
    k.define_method :command do
      command_str
    end
    k.new
  end

  def build_test_command_instance(args_str)
    TestCommandHelper.build_command_instance("#{TestCommandHelper.test_command} #{args_str}")
  end
end

RSpec.configure do |config|
  config.include TestCommandHelper
end
