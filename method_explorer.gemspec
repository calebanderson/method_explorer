# frozen_string_literal: true
require_relative 'lib/method_explorer/version'

Gem::Specification.new do |spec|
  spec.name        = 'method_explorer'
  spec.version     = MethodExplorer::VERSION
  spec.authors     = ['calebanderson']
  spec.email       = ['caleb.r.anderson.1@gmail.com']
  spec.homepage    = 'https://github.com/calebanderson/method_explorer'
  spec.summary     = 'Helpers for getting useful method information'
  spec.description = 'Helpers for getting useful method information'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 2.2'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'TODO: Set to http://mygemserver.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/calebanderson/method_explorer'
  spec.metadata['changelog_uri'] = 'https://github.com/calebanderson/method_explorer/blob/master/CHANGELOG.md'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '>= 4.2'

  spec.add_dependency 'shared_helpers'
  spec.add_dependency 'responsive_console'
end
