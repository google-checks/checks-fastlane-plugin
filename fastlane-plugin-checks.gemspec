lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/checks/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-checks'
  spec.version       = Fastlane::Checks::VERSION
  spec.author       = ['Sherzat Aitbayev']

  spec.summary       = 'Fastlane plugin for Checks (checks.google.com)'
  spec.homepage      = "https://github.com/google-checks/fastlane-plugin-checks"
  spec.license       = "Apache-2.0"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency('faraday')
  spec.add_dependency('googleauth')
  spec.add_dependency('tty-spinner')

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('fastlane', '>= 2.217.0')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop', '1.50.2')
  spec.add_development_dependency('rubocop-performance')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('webmock')
  spec.add_development_dependency('pry')
end
