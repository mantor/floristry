$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'ruote/trail/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'ruote-trail-on-rails'
  s.version     = RuoteTrail::VERSION
  s.authors     = ['Danny Fullerton']
  s.email       = ['northox@mantor.org']
  s.homepage    = 'https://github.com/northox/ruote-trail-on-rails'
  s.summary     = %q{Ruote-kit for Rails missing part.}
  s.description = %q{Represent complete Ruote's workflow using standard rails facilities, e.g. render, partials, etc.}

  s.files = Dir["{app,config,lib}/**/*"] + %w(LICENSE Rakefile README.md)
  s.test_files = Dir["test/**/*"]

  s.add_runtime_dependency 'rails', '>= 4.1.0'
  s.add_runtime_dependency 'ruote', '>= 2.3.0'
  s.add_runtime_dependency 'protected_attributes', '>= 1.0.7' # TODO switch to strong_parameters
  s.add_runtime_dependency 'active_attr'
end
