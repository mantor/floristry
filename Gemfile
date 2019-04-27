source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in floristry.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# All this is used by the dummy app used for test/specs
group :test do
  gem 'simple_form', '~> 3.1'
  gem 'statesman', '~> 2.0.1'
  gem 'statesman-events', '~> 0.0.1'
  gem "jquery-rails"
  gem "sqlite3", '~> 1.3.6'
  gem "twitter-bootstrap-rails"
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]
