# frozen_string_literal: true

module SgTinyBackup
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/sg_tiny_backup.rake", __dir__)
    end
  end
end
