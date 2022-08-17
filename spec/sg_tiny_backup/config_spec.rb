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
      YAML

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      expect(config.s3["bucket"]).to eq "my_bucket"
      expect(config.s3["prefix"]).to eq "my_prefix"
      expect(config.s3["access_key_id"]).to eq "MY_ACCESS_KEY_ID"
      expect(config.s3["secret_access_key"]).to eq "MY_SECRET_ACCESS_KEY"
    end

    it "reads an config file with erb" do
      yaml = <<~YAML
        ---
        s3:
          bucket: my_bucket
          prefix: my_prefix
          access_key_id: <%= ENV.fetch('AWS_ACCESS_KEY_ID') %>
          secret_access_key: <%= ENV.fetch('AWS_SECRET_ACCESS_KEY') %>
      YAML

      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("AWS_ACCESS_KEY_ID").and_return("MY_ENV_ACCESS_KEY_ID")
      allow(ENV).to receive(:fetch).with("AWS_SECRET_ACCESS_KEY").and_return("MY_ENV_SECRET_ACCESS_KEY")

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      expect(config.s3["bucket"]).to eq "my_bucket"
      expect(config.s3["prefix"]).to eq "my_prefix"
      expect(config.s3["access_key_id"]).to eq "MY_ENV_ACCESS_KEY_ID"
      expect(config.s3["secret_access_key"]).to eq "MY_ENV_SECRET_ACCESS_KEY"
    end
  end
end
