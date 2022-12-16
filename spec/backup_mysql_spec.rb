# frozen_string_literal: true

require "fileutils"

RSpec.describe "Backup database" do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:tmpdir) { "tmp/mysql_dump" }
  let(:yaml) do
    YAML.safe_load(
      File.read("config/database.yml"),
      permitted_classes: [],
      permitted_symbols: [],
      aliases: true
    )
  end
  let(:database) { yaml.dig("test_mysql", "database") || "sg_tiny_backup_test" }
  let(:host) { yaml.dig("test_mysql", "host") || "127.0.0.1" }
  let(:port) { yaml.dig("test_mysql", "port") || 3306 }
  let(:username) { yaml.dig("test_mysql", "username") || "root" }
  let(:password) { yaml.dig("test_mysql", "password") || "password" }
  let(:encryption_key) do
    "bd70e53cb1df807b17c11bf79197948bdf1dda91486b026600a6ad9c68362706a317a5f811484f7154a7efb607e2dfead641c9e159cb81bd42bc77eea706c603"
  end
  let(:decryption_command) do
    parts = ["openssl enc -d -pbkdf2"]
    parts << "-#{SgTinyBackup::Commands::Openssl::CIPHER}"
    parts << "-iter #{SgTinyBackup::Commands::Openssl::ITER}"
    parts << "-pass pass:#{encryption_key}"
    parts << "-in #{tmpdir}/test_dump.sql.gz.enc | gunzip > #{tmpdir}/test_dump.sql"
    parts.join(" ")
  end
  let(:sql) do
    <<~SQL
      CREATE TABLE users (
          id bigint NOT NULL,
          email text NOT NULL
      );
    SQL
  end
  let(:mysql_command) { "mysql -h #{host} -P #{port} -u #{username}" }

  before do
    env = {
      "MYSQL_PWD" => password,
    }
    system(env, "#{mysql_command} -e 'DROP DATABASE IF EXISTS #{database}'", exception: true)
    system(env, "#{mysql_command} -e 'CREATE DATABASE #{database}'", exception: true)
    system(env, %(#{mysql_command} #{database} -e "#{sql}"), exception: true)
    FileUtils.rm_rf(tmpdir)
    FileUtils.mkdir_p(tmpdir)
  end

  after do
    env = {
      "MYSQL_PWD" => password,
    }
    system(env, "#{mysql_command} -e 'DROP DATABASE IF EXISTS #{database}'", exception: true)
    FileUtils.rm_rf(tmpdir)
  end

  it "creates encyrpted dump and decrypts it" do
    config = SgTinyBackup::Config.new(
      s3: {},
      mysqldump: {
        "extra_options" => "--single-transaction --quick --hex-blob",
      },
      encryption_key: encryption_key,
      db: yaml["test_mysql"]
    )
    runner = SgTinyBackup::Runner.new(config: config, basename: "#{tmpdir}/test_dump", local: true)
    runner.run

    encrypted_binary = File.read("#{tmpdir}/test_dump.sql.gz.enc")
    expect(encrypted_binary).to start_with "Salted"

    system(decryption_command, exception: true)
    decrypted = File.read("#{tmpdir}/test_dump.sql")
    expect(decrypted).to include "CREATE TABLE `users`"
    expect(decrypted).to include "`id` bigint NOT NULL"
    expect(decrypted).to include "`email` text NOT NULL"
  end
end
