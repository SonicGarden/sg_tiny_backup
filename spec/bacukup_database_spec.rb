# frozen_string_literal: true

require "fileutils"

RSpec.describe "Backup database" do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:yaml) do
    YAML.safe_load(
      File.read("config/database.yml"),
      permitted_classes: [],
      permitted_symbols: [],
      aliases: true
    )
  end
  let(:pg_database) { yaml.dig("test", "database") }
  let(:pg_host) { yaml.dig("test", "host") || "localhost" }
  let(:pg_port) { yaml.dig("test", "port") || 5432 }
  let(:pg_username) { yaml.dig("test", "username") || "postgres" }
  let(:pg_password) { yaml.dig("test", "password") || "postgres" }
  let(:encryption_key) do
    "bd70e53cb1df807b17c11bf79197948bdf1dda91486b026600a6ad9c68362706a317a5f811484f7154a7efb607e2dfead641c9e159cb81bd42bc77eea706c603"
  end
  let(:decryption_command) do
    parts = ["openssl enc -d -pbkdf2"]
    parts << "-#{SgTinyBackup::Commands::Openssl::CIPHER}"
    parts << "-iter #{SgTinyBackup::Commands::Openssl::ITER}"
    parts << "-pass pass:#{encryption_key}"
    parts << "-in tmp/dump/test_dump.sql.gz.enc | gunzip > tmp/dump/test_dump.sql"
    parts.join(" ")
  end
  let(:sql) do
    <<~SQL
      CREATE TABLE public.users (
          id bigint NOT NULL,
          email character varying DEFAULT ''::character varying NOT NULL
      );
    SQL
  end

  before do
    env = {
      "PGPASSWORD" => pg_password,
    }
    system(env, "dropdb --if-exists -h #{pg_host} -p #{pg_port} -U #{pg_username} #{pg_database} 2> /dev/null", exception: true)
    system(env, "createdb -h #{pg_host} -p #{pg_port} -U #{pg_username} #{pg_database}", exception: true)
    system(env, %(psql --quiet -h #{pg_host} -p #{pg_port} -U #{pg_username} -d #{pg_database} -c "#{sql}"))
    # system(env, %(pg_dump -xc --if-exists --encoding=utf8 -h #{pg_host} -p #{pg_port} -U #{pg_username} #{pg_database}))
    FileUtils.rm_rf("tmp/dump")
    FileUtils.mkdir_p("tmp/dump")
  end

  after do
    env = {
      "PGPASSWORD" => pg_password,
    }
    system(env, "dropdb --if-exists -h #{pg_host} -p #{pg_port} -U #{pg_username} #{pg_database}", exception: true)
    FileUtils.rm_rf("tmp/dump")
  end

  it "creates encyrpted dump and decrypts it" do
    config = SgTinyBackup::Config.new(
      s3: {
      },
      pg_dump: {
        "extra_options" => "-xc --if-exists --encoding=utf8",
      },
      encryption_key: encryption_key,
      db: yaml["test"]
    )
    runner = SgTinyBackup::Runner.new(config: config, basename: "tmp/dump/test_dump", local: true)
    runner.run

    encrypted_binary = File.read("tmp/dump/test_dump.sql.gz.enc")
    expect(encrypted_binary).to start_with "Salted"

    system(decryption_command, exception: true)
    decrypted = File.read("tmp/dump/test_dump.sql")
    expect(decrypted).to include sql
  end
end
