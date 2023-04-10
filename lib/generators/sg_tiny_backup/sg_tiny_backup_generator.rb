# frozen_string_literal: true

class SgTinyBackupGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  desc "For sg_tiny_backup config files"
  def sg_tiny_backup
    copy_file "config/sg_tiny_backup.yml"
    copy_file "config/initializers/sg_tiny_backup.rb"
  end
end
