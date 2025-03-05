# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'klaus/version'

Gem::Specification.new do |spec|
  spec.name          = 'Klaus'
  spec.version       = Klaus::VERSION
  spec.authors       = ['Johannes Daxböck']
  spec.email         = ['johdax@fastmail.fm']

  spec.summary       = 'A Prolog interpreter implemented in Ruby'
  spec.description   = 'Klaus aims to become an embed-able ISO compliant performant Prolog interpreter written in pure Ruby'
  spec.homepage      = 'https://github.com/dingsdax/klaus'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.4.2'

  # runtime dependencies
  spec.add_dependency 'parslet', '~> 2.0'
  spec.add_dependency 'zeitwerk', '~> 2.7'

  # development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'irb', '~> 1.15'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'ostruct', '~> 0.6'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'reline', '~> 0.6'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
