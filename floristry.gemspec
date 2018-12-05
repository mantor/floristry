$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require 'floristry/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'floristry'
  s.version     = Floristry::VERSION
  s.authors     = ['Danny Fullerton', 'Jean-Francois Rioux']
  s.email       = ['danny@mantor.org', 'jfrioux@mantor.org']
  s.homepage    = 'https://github.com/mantor/floristry'
  s.summary     = %q{Visualize and interact with Flor's workflow engine through Rails facilities.}
  s.description = %q{Floristry brings the Rails web framework as a UI to Flor's workflows engine. You can represent workflows using standard Rails facilities (e.g. partials, helpers) and interact with tasks just like any other form using ActiveRecord. Think of it like Facebook's timeline but instead of being linear, the backend is a workflow engine - actually a full workflow programming language with concurrence, loops and conditions.}
  s.license	= "GPL2"

  s.files = Dir["{app,config,db,lib}/**/*"] + %w(LICENSE Rakefile README.md)
  s.test_files = Dir["spec/**/*"]

  s.add_runtime_dependency 'rails', '>= 4.2.8'
  s.add_runtime_dependency 'thor', '0.19.1'
  s.add_runtime_dependency 'protected_attributes', '>= 1.0.7'
  s.add_runtime_dependency 'active_attr'
  s.add_runtime_dependency 'flor'
  s.add_runtime_dependency 'httpclient'

  s.add_development_dependency 'rspec-rails', '~> 3'
  s.add_development_dependency 'rspec-activemodel-mocks'
end
