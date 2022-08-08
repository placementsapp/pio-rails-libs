require_relative 'lib/pio_rails_libs/version'

Gem::Specification.new do |spec|
  spec.name          = "pio_rails_libs"
  spec.version       = PioRailsLibs::VERSION
  spec.authors       = ["Zubin Wang"]
  spec.email         = ["zubin.wang@gmail.com"]

  spec.summary       = %q{Common code for PIO Rails based apps.}
  spec.description   = %q{Common code for PIO Rails based apps so we don't have to repeat ourselves too much.}
  spec.homepage      = "https://placements.io"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  #spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 6.0"
  spec.add_dependency "resque", "~> 2.2.1"
  spec.add_dependency "resque-heroku", "~> 0.1.0"
  spec.add_dependency "resque-heroku-signals", "~> 2.2.1"
  spec.add_dependency "resque-retry", "~> 1.7.6"
  spec.add_dependency "resque-scheduler", "~> 4.5.0"

  spec.add_development_dependency "rspec", "~> 3.2"
end
