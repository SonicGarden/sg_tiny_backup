# frozen_string_literal: true

require "fileutils"

RSpec.describe "Backup log" do
  let(:output_dir) { "tmp/log" }
  let(:extracted_dir) { "#{output_dir}/extracted" }

  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p extracted_dir
  end

  after do
    FileUtils.rm_rf output_dir
  end

  context "without missing files" do
    it "creates log backup" do
      config = SgTinyBackup::Config.new(
        s3: {},
        log: {
          "files" => [
            "spec/test_data/log/test.log",
            "spec/test_data/log/test.log.1",
          ],
        },
        encryption_key: "dummy",
        db: {}
      )
      runner = SgTinyBackup::Runner.new(config: config, target: "log", basename: "#{output_dir}/test_log", local: true)
      runner.run

      system("tar -xf #{output_dir}/test_log.tar.gz -C #{extracted_dir}", exception: true)
      expect(File.read("#{extracted_dir}/spec/test_data/log/test.log")).to eq "Hello, World!\n"
      expect(File.read("#{extracted_dir}/spec/test_data/log/test.log.1")).to eq "Goodbye, World!\n"
    end
  end

  context "with existing optional files" do
    it "creates log backup without error" do
      config = SgTinyBackup::Config.new(
        s3: {},
        log: {
          "files" => [
            "spec/test_data/log/test.log",
          ],
          "optional_files" => [
            "spec/test_data/log/test.log.1",
          ],
        },
        encryption_key: "dummy",
        db: {}
      )
      runner = SgTinyBackup::Runner.new(config: config, target: "log", basename: "#{output_dir}/test_log", local: true)
      runner.run

      system("tar -xf #{output_dir}/test_log.tar.gz -C #{extracted_dir}", exception: true)
      expect(File.read("#{extracted_dir}/spec/test_data/log/test.log")).to eq "Hello, World!\n"
      expect(File.read("#{extracted_dir}/spec/test_data/log/test.log.1")).to eq "Goodbye, World!\n"
    end
  end

  context "with missing required files" do
    it "raises error" do
      config = SgTinyBackup::Config.new(
        s3: {},
        log: {
          "files" => [
            "spec/test_data/log/test.log",
            "spec/test_data/log/test.log.missing",
          ],
        },
        encryption_key: "dummy",
        db: {}
      )
      runner = SgTinyBackup::Runner.new(config: config, target: "log", basename: "#{output_dir}/test_log", local: true)
      expect do
        runner.run
      end.to raise_error SgTinyBackup::BackupFailed
    end
  end

  context "with missing optional files" do
    let(:log) { StringIO.new }

    before do
      allow(SgTinyBackup).to receive(:logger).and_return(Logger.new(log))
    end

    it "creates log backup without error" do
      config = SgTinyBackup::Config.new(
        s3: {},
        log: {
          "files" => [
            "spec/test_data/log/test.log",
          ],
          "optional_files" => [
            "spec/test_data/log/test.log.missing",
          ],
        },
        encryption_key: "dummy",
        db: {}
      )
      runner = SgTinyBackup::Runner.new(config: config, target: "log", basename: "#{output_dir}/test_log", local: true)
      runner.run

      expect(log.string).to include "WARN -- : tar: missing files: spec/test_data/log/test.log.missing\n"

      system("tar -xf #{output_dir}/test_log.tar.gz -C #{extracted_dir}", exception: true)
      expect(File.read("#{extracted_dir}/spec/test_data/log/test.log")).to eq "Hello, World!\n"
    end
  end

  context "with no files" do
    let(:log) { StringIO.new }

    before do
      allow(SgTinyBackup).to receive(:logger).and_return(Logger.new(log))
    end

    it "creates empty log backup and raise error" do
      config = SgTinyBackup::Config.new(
        s3: {},
        log: {
          "optional_files" => [
            "spec/test_data/log/test.log.missing1",
            "spec/test_data/log/test.log.missing2",
          ],
        },
        encryption_key: "dummy",
        db: {}
      )
      runner = SgTinyBackup::Runner.new(config: config, target: "log", basename: "#{output_dir}/test_log", local: true)
      runner.run

      expect(log.string).to include "WARN -- : tar: missing files: spec/test_data/log/test.log.missing1, spec/test_data/log/test.log.missing2\n"

      system("tar -xf #{output_dir}/test_log.tar.gz -C #{extracted_dir}", exception: true)
      expect(Dir.entries(extracted_dir)).to contain_exactly(".", "..")
    end
  end
end
