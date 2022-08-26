# frozen_string_literal: true

RSpec.describe SgTinyBackup::Runner do
  describe "#plain_commands" do
    it "generates database backup command" do
      yaml = <<~YAML
        s3:
          db:
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
          host: localhost
          port: 15432
          username: postgres
          password: MY_DB_PASSWORD
      YAML

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      runner = SgTinyBackup::Runner.new(config: config, basename: "01234567")
      commands = runner.plain_commands
      expect(commands[0]).to eq "pg_dump -xc --if-exists --encoding=utf8 --username=postgres --host=localhost --port=15432 my_database"
      expect(commands[1]).to eq "gzip"
      expect(commands[2]).to eq "openssl enc -aes-256-cbc -pbkdf2 -iter 10000 -pass env:SG_TINY_BACKUP_ENCRYPTION_KEY"
      expect(commands[3]).to eq "aws s3 cp --expected-size 100000000000 - s3://my_bucket/backup/database_01234567.sql.gz.enc"
    end

    it "generates log backup command" do
      yaml = <<~YAML
        s3:
          log:
            bucket: my_bucket
            prefix: backup/log_
            access_key_id: MY_ACCESS_KEY_ID
            secret_access_key: MY_SECRET_ACCESS_KEY
        log:
          files:
            - log/production.log
            - log/production.log.1
      YAML

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      runner = SgTinyBackup::Runner.new(config: config, target: "log", basename: "01234567")
      commands = runner.plain_commands
      expect(commands[0]).to eq "tar -c log/production.log log/production.log.1"
      expect(commands[1]).to eq "gzip"
      expect(commands[2]).to eq "aws s3 cp - s3://my_bucket/backup/log_01234567.tar.gz"
    end
  end

  describe "#env" do
    it "generates backup envrionment variables" do
      yaml = <<~YAML
        s3:
          db:
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
          host: localhost
          port: 15432
          username: postgres
          password: MY_DB_PASSWORD
      YAML

      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      runner = SgTinyBackup::Runner.new(config: config, basename: "01234567")
      env = runner.env
      expected = {
        "PGPASSWORD" => "MY_DB_PASSWORD",
        "SG_TINY_BACKUP_ENCRYPTION_KEY" => "MY_ENCRYPTION_KEY",
        "AWS_ACCESS_KEY_ID" => "MY_ACCESS_KEY_ID",
        "AWS_SECRET_ACCESS_KEY" => "MY_SECRET_ACCESS_KEY",
      }
      expect(env).to eq expected
    end
  end

  describe "raise_on_error" do
    let(:pipeline) do
      pipeline = instance_double(SgTinyBackup::Pipeline)
      allow(pipeline).to receive(:run)
      allow(pipeline).to receive(:succeeded?).and_return(false)
      allow(pipeline).to receive(:failed?).and_return(true)
      allow(pipeline).to receive(:warning_messages).and_return("")
      allow(pipeline).to receive(:error_messages).and_return("Error occured")
      pipeline
    end
    let(:runner) do
      yaml = <<~YAML
        s3:
          db:
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
          host: localhost
          port: 15432
          username: postgres
          password: MY_DB_PASSWORD
      YAML
      config = SgTinyBackup::Config.read(StringIO.new(yaml))
      runner = SgTinyBackup::Runner.new(config: config, basename: "01234567")
      allow(runner).to receive(:pipeline) { pipeline }
      runner
    end

    context "when SgTinyBackup.raise_on_error is true" do
      before do
        allow(SgTinyBackup).to receive(:raise_on_error).and_return(true)
      end

      it "raises error" do
        logger = instance_spy(Logger)
        allow(SgTinyBackup).to receive(:logger).and_return(logger)

        expect do
          runner.run
        end.to raise_error SgTinyBackup::BackupFailed, "Error occured"

        expect(logger).to have_received(:error).with("Error occured")
      end
    end

    context "when SgTinyBackup.raise_on_error is false" do
      before do
        allow(SgTinyBackup).to receive(:raise_on_error).and_return(false)
      end

      it "does not raise error" do
        logger = instance_spy(Logger)
        allow(SgTinyBackup).to receive(:logger).and_return(logger)

        expect(runner.run).to be_falsey

        expect(logger).to have_received(:error).with("Error occured")
      end
    end
  end
end
