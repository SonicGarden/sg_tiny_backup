# frozen_string_literal: true

SgTinyBackup.error_handler = lambda do |error|
  raise error unless error.is_a?(SgTinyBackup::BackupWarning) && error.message == "tar: missing files: log/production.log.1"
end
