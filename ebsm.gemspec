# frozen_string_literal: true

require_relative 'lib/ebsm/version'

Gem::Specification.new do |spec|
  spec.name          = 'ebsm'
  spec.version       = Ebsm::VERSION
  spec.authors       = ['David Siaw']
  spec.email         = ['874280+davidsiaw@users.noreply.github.com']

  spec.summary       = 'Literate binary generator'
  spec.description   = 'A templating layer over bsm2 that lets you mix prose, Ruby scripting, and byte data in one source file.'
  spec.homepage      = 'https://github.com/davidsiaw/ebsm'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/davidsiaw/ebsm'
  spec.metadata['changelog_uri'] = 'https://github.com/davidsiaw/ebsm'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['{exe,data,lib}/**/*'] + %w[Gemfile ebsm.gemspec]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bsm'
end
