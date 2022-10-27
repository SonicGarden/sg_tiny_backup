# frozen_string_literal: true

RSpec.describe SgTinyBackup::Spawner do
  describe "Spawn error" do
    it "raises SpawnError" do
      commands = [
        build_command_instance("echo Hello, World"),
        build_command_instance("cat"),
      ]

      spawner = SgTinyBackup::Spawner.new(commands: commands)
      allow(spawner).to receive(:spawn_pipeline_command).and_raise(StandardError.new("Test error"))

      expect do
        spawner.spawn_and_wait
      end.to raise_error(SgTinyBackup::SpawnError, /StandardError: Test error/)
    end
  end
end
