$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'floristry/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'floristry'
  s.version     = Floristry::VERSION
  s.authors     = ['Danny Fullerton']
  s.email       = ['northox@mantor.org']
  s.homepage    = 'https://github.com/northox/floristry'
  s.summary     = %q{What ActiveRecord is to database but for Flor workflow engine.}
  s.description = %q{Represent complete Flor workflows using standard rails facilities, e.g. render, partials, etc.}

  s.files = Dir["{app,config,lib}/**/*"] + %w(LICENSE Rakefile README.md)
  s.test_files = Dir["spec/**/*"]

  s.add_runtime_dependency 'rails', '>= 4.2.8'
  s.add_runtime_dependency 'thor', '0.19.1'
  s.add_runtime_dependency 'protected_attributes', '>= 1.0.7' # TODO switch to strong_parameters
  s.add_runtime_dependency 'active_attr'
  s.add_runtime_dependency 'flor'
  s.add_runtime_dependency 'httpclient'

  s.add_development_dependency 'rspec-rails', '~> 3'
  s.add_development_dependency 'rspec-activemodel-mocks'
end