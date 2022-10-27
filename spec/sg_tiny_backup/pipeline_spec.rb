# frozen_string_literal: true

RSpec.describe SgTinyBackup::Pipeline do
  describe "#run" do
    it "succeeds" do
      pipeline = SgTinyBackup::Pipeline.new
      pipeline << build_command_instance("echo Hello, World")
      pipeline << build_command_instance("cat")

      pipeline.run

      expect(pipeline).to be_succeeded
      expect(pipeline.stdout).to eq "Hello, World\n"
      expect(pipeline.stderr).to be_empty
      expect(pipeline.error_messages).to be_empty
    end

    it "succeeds with command exit code 1" do
      pipeline = SgTinyBackup::Pipeline.new
      pipeline << build_test_command_instance("name=first exit=1 stdout=first_output stderr=first_error", success_codes: [0, 1])
      pipeline << build_command_instance("cat")

      pipeline.run

      expect(pipeline).to be_succeeded
      expect(pipeline.stdout).to eq "first_output\n"
      expect(pipeline.stderr).to eq "first_error\n"
      expect(pipeline.warning_messages).to eq <<~END_OF_MESSAGE
        STDERR messages:

        first_error

      END_OF_MESSAGE
    end

    it "get stdout, stderr and error_messages" do
      pipeline = SgTinyBackup::Pipeline.new
      pipeline << build_test_command_instance("name=first exit=42 stdout=first_output stderr=first_error")
      pipeline << build_test_command_instance("name=second exit=0 read_stdin stdout=second_output stderr=second_error")

      pipeline.run

      expect(pipeline).to be_failed
      expect(pipeline.stdout).to eq <<~END_OF_MESSAGE
        second: got: first_output
        second_output
      END_OF_MESSAGE
      expect(pipeline.stderr).to eq <<~END_OF_MESSAGE
        first_error
        second_error
      END_OF_MESSAGE
      expect(pipeline.error_messages).to eq <<~END_OF_MESSAGE
        STDERR messages:

        first_error
        second_error

        The following errors were returned:

        `#{TestCommandHelper.test_command} name=first exit=42 stdout=first_output stderr=first_error` returned exit code: 42
      END_OF_MESSAGE
    end

    it "get errors when a command does not exist" do
      pipeline = SgTinyBackup::Pipeline.new
      pipeline << build_command_instance("true")
      pipeline << build_command_instance("a_command_that_does_not_exist")

      pipeline.run

      expect(pipeline).to be_failed
      expect(pipeline.stdout).to be_empty
      expect(pipeline.stderr).to match(/sh:.*not found/)

      regex_str = <<~END_OF_MESSAGE
        STDERR messages:

        sh:.*not found

        The following errors were returned:

        `a_command_that_does_not_exist` returned exit code: 127
      END_OF_MESSAGE
      expect(pipeline.error_messages).to match Regexp.new(regex_str)
    end
  end
end
