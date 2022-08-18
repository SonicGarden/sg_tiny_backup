# frozen_string_literal: true

RSpec.describe SgTinyBackup::Config do
  describe ".read" do
    it "reads an config file" do
      yaml = <<~YAML
        ---
        s3:
          bucket: my_bucket
          prefix: my_prefix
          access_key_id: MY_ACCESS_KEY_ID
          secret_access_key: MY_SECRET_ACCESS_KEY
        pg_dump:
          extra_options: -xc --if-exists --encoding=utf8
        encryption_key: MY_ENCRYPTION_KEY
      YAML

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      expect(config.s3).to eq ({
        "bucket" => "my_bucket",
        "prefix" => "my_prefix",
        "access_key_id" => "MY_ACCESS_KEY_ID",
        "secret_access_key" => "MY_SECRET_ACCESS_KEY"
      })
      expect(config.pg_dump).to eq ({ "extra_options" => "-xc --if-exists --encoding=utf8" })
      expect(config.encryption_key).to eq "MY_ENCRYPTION_KEY"
    end

    it "reads an config file with erb" do
      yaml = <<~YAML
        ---
        s3:
          bucket: my_bucket
          prefix: my_prefix
          access_key_id: <%= ENV.fetch('AWS_ACCESS_KEY_ID') %>
          secret_access_key: <%= ENV.fetch('AWS_SECRET_ACCESS_KEY') %>
        encryption_key: <%= ENV.fetch('ENCRYPTION_KEY') %>
      YAML

      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("AWS_ACCESS_KEY_ID").and_return("MY_ENV_ACCESS_KEY_ID")
      allow(ENV).to receive(:fetch).with("AWS_SECRET_ACCESS_KEY").and_return("MY_ENV_SECRET_ACCESS_KEY")
      allow(ENV).to receive(:fetch).with("ENCRYPTION_KEY").and_return("MY_ENV_ENCRYPTION_KEY")

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      expect(config.s3).to eq ({
        "bucket" => "my_bucket",
        "prefix" => "my_prefix",
        "access_key_id" => "MY_ENV_ACCESS_KEY_ID",
        "secret_access_key" => "MY_ENV_SECRET_ACCESS_KEY"
      })
      expect(config.encryption_key).to eq "MY_ENV_ENCRYPTION_KEY"
    end
  end
end
