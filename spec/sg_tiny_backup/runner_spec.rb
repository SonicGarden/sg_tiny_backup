# frozen_string_literal: true

RSpec.describe SgTinyBackup::Runner do
  describe "#command" do
    it "generates backup command" do
      yaml = <<~YAML
        s3:
          bucket: my_bucket
          prefix: backup/database_
          access_key_id: MY_ACCESS_KEY_ID
          secret_access_key: MY_SECRET_ACCESS_KEY
          expected_upload_size: 100000000000
        pg_dump:
          extra_options: -xc --if-exists --encoding=utf8
        encryption_key: MY_ENCRYPTION_KEY
        db:
          database: my_database
          user: postgres
          host: localhost
          port: 15432
          password: MY_DB_PASSWORD
      YAML

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      runner = SgTinyBackup::Runner.new(config: config, basename: "01234567")
      commands = runner.command.split("|").map(&:strip)
      # rubocop:disable Layout/LineLength
      expect(commands[0]).to eq "pg_dump -xc --if-exists --encoding=utf8 --username=postgres --host=localhost --port=15432 my_database"
      expect(commands[1]).to eq "gzip"
      expect(commands[2]).to eq "openssl enc -aes-256-cbc -pbkdf2 -iter 10000 -pass env:SG_TINY_BACKUP_ENCRYPTION_KEY"
      expect(commands[3]).to eq "aws s3 cp --expected-size 100000000000 - s3://my_bucket/backup/database_01234567.sql.gz.enc"
      # rubocop:enable Layout/LineLength
    end
  end

  describe "#env" do
    it "generates backup envrionment variables" do
      yaml = <<~YAML
        s3:
          bucket: my_bucket
          prefix: backup/database_
          access_key_id: MY_ACCESS_KEY_ID
          secret_access_key: MY_SECRET_ACCESS_KEY
          expected_upload_size: 100000000000
        pg_dump:
          extra_options: -xc --if-exists --encoding=utf8
        encryption_key: MY_ENCRYPTION_KEY
        db:
          database: my_database
          user: postgres
          host: localhost
          port: 15432
          password: MY_DB_PASSWORD
      YAML

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      runner = SgTinyBackup::Runner.new(config: config, basename: "01234567")
      env = runner.env
      expect(env).to eq ({
        "PGPASSWORD"=> "MY_DB_PASSWORD",
        "SG_TINY_BACKUP_ENCRYPTION_KEY"=>"MY_ENCRYPTION_KEY",
        "AWS_ACCESS_KEY_ID"=>"MY_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"=>"MY_SECRET_ACCESS_KEY"
      })
    end
  end
end
