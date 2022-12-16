# frozen_string_literal: true

RSpec.describe SgTinyBackup::PipelineBuilders::Db do
  describe "#build" do
    context "when database adapter is not set" do
      it "raises an error" do
        yaml = <<~YAML
          s3:
            db:
              bucket: my_bucket
              prefix: backup/database
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
        db = SgTinyBackup::PipelineBuilders::Db.new(config: config, basename: "01234567", local: false)

        expect { db.build }.to raise_error "database adapter is not specified in your config."
      end
    end

    context "when unsupport database adapter is set" do
      it "raises an error" do
        yaml = <<~YAML
          s3:
            db:
              bucket: my_bucket
              prefix: backup/database
              access_key_id: MY_ACCESS_KEY_ID
              secret_access_key: MY_SECRET_ACCESS_KEY
              expected_upload_size: 100000000000
          pg_dump:
            extra_options: -xc --if-exists --encoding=utf8
          encryption_key: MY_ENCRYPTION_KEY
          db:
            adapter: sqlite3
            database: my_database
            host: localhost
            port: 15432
            username: postgres
            password: MY_DB_PASSWORD
        YAML
        config = SgTinyBackup::Config.read(StringIO.new(yaml))
        db = SgTinyBackup::PipelineBuilders::Db.new(config: config, basename: "01234567", local: false)

        expect { db.build }.to raise_error "database adapter `sqlite3` is not supported."
      end
    end
  end
end
