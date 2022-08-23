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
    SgTinyBackup.logger.info "Starting backup to #{url}"
    if runner.run
      SgTinyBackup.logger.info "Backup done!"
    else
      SgTinyBackup.logger.error "Backup failed!"
      exit 1
    end
  end

  desc "Backup to current directory"
  task backup_local: :environment do
    config = SgTinyBackup::Config.read_file(default_config_path)
    runner = SgTinyBackup::Runner.new(config: config, basename: Time.now.strftime("%Y%m%d%H%M%S"), local: true)
    SgTinyBackup.logger.info "Starting backup to #{runner.base_filename}"
    if runner.run
      SgTinyBackup.logger.info "Backup done!"
    else
      SgTinyBackup.logger.error "Backup failed!"
      exit 1
    end
  end

  desc "Show backup command"
  task command: :environment do
    config = SgTinyBackup::Config.read_file(default_config_path)
    puts SgTinyBackup::Runner.new(config: config, basename: Time.now.strftime("%Y%m%d%H%M%S")).piped_command
  end

  desc "Show backup command environment variables"
  task env: :environment do
    config = SgTinyBackup::Config.read_file(default_config_path)
    puts SgTinyBackup::Runner.new(config: config, basename: Time.now.strftime("%Y%m%d%H%M%S")).env
  end

  desc "Show decryption command"
  task decryption_command: :environment do
    puts SgTinyBackup::Commands::Openssl.decryption_command
  end
end
