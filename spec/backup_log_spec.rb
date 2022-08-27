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

  it "creates log backup" do
    config = SgTinyBackup::Config.new(
      s3: {
      },
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
