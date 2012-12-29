source 'https://rubygems.org'

gem 'rails', '3.2.9'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-datatables-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'twitter-bootstrap-rails'
    gem 'less-rails'
      gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end

gem 'active_attr'
gem 'best_in_place'
gem 'haml-rails'
gem 'inherited_resources'
gem 'jquery-rails'
gem 'public_suffix'
gem 'redis'
gem 'simple_form'
gem 'unicorn'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'foreman'
  gem 'guard'
    gem 'rb-inotify' if RUBY_PLATFORM.downcase.include?("linux")
    gem 'rb-fsevent' if RUBY_PLATFORM.downcase.include?("darwin")
  gem 'guard-bundler'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-unicorn'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'rspec-rails'
end

group :test do
  gem 'shoulda-matchers'
end
