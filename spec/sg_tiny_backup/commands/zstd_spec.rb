# frozen_string_literal: true

RSpec.describe SgTinyBackup::Commands::Zstd do
  describe "#command" do
    it "returns zstd command without level" do
      expect(SgTinyBackup::Commands::Zstd.new.command).to eq "zstd -c"
    end

    it "returns zstd command with level" do
      expect(SgTinyBackup::Commands::Zstd.new(level: 3).command).to eq "zstd -c -3"
    end

    it "returns zstd command with ultra level" do
      expect(SgTinyBackup::Commands::Zstd.new(level: 20).command).to eq "zstd -c --ultra -20"
      expect(SgTinyBackup::Commands::Zstd.new(level: 22).command).to eq "zstd -c --ultra -22"
    end
  end
end
