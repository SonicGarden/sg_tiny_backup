# frozen_string_literal: true

namespace :sg_tiny_backup do
  default_config_path = ENV["SG_TINY_BACKUP_CONFIG_PATH"] || "config/sg_tiny_backup.yml"

  desc "Generate config file"
  task generate: :environment do
    SgTinyBackup::Config.generate_template_file(default_config_path)
  end

  desc "Backup and upload to s3"
  task backup: :environment do
    config = SgTinyBackup::Config.read_file(default_config_path)
    runner = SgTinyBackup::Runner.new(config: config, basename: Time.now.strftime("%Y%m%d%H%M%S"))
    url = runner.s3_destination_url
    puts "Starting backup to #{url}"
    runner.run
    puts "Done!"
  end

  desc "Show backup command"
  task command: :environment do
    config = SgTinyBackup::Config.read_file(default_config_path)
    puts SgTinyBackup::Runner.new(config: config, basename: Time.now.strftime("%Y%m%d%H%M%S")).command
  end

  desc "Show decryption command"
  task decryption_command: :environment do
    puts SgTinyBackup::Commands::Openssl.decryption_command
  end
end
