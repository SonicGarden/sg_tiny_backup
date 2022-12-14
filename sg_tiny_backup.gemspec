# frozen_string_literal: true

require_relative "lib/sg_tiny_backup/version"

Gem::Specification.new do |spec|
  spec.name          = "sg_tiny_backup"
  spec.version       = SgTinyBackup::VERSION
  spec.authors       = ["Shunichi Ikegami"]
  spec.email         = ["shunichi@sonicgarden.jp"]

  spec.summary       = "Tiny backup"
  spec.description   = "Backup postgresql database and logs to S3"
  spec.homepage      = "https://github.com/SonicGarden/sg_tiny_backup"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  # spec.metadata['allowed_push_host'] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SonicGarden/sg_tiny_backup"
  spec.metadata["changelog_uri"] = "https://github.com/SonicGarden/sg_tiny_backup/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
