# frozen_string_literal: true

module SgTinyBackup
  class Error < StandardError
  end

  class BackupFailed < Error
  end

  class SpawnError < Error
    def initialize(msg, inner_error)
      inner_message = inner_error.message
      inner_class_name = inner_error.class.name

      message = msg.dup
      message << "\n--- Inner error ---\n"
      message << "#{inner_class_name}: " unless inner_message.start_with?(inner_class_name)
      message << inner_message
      super message
    end
  end
end
