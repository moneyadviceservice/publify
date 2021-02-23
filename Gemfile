source 'https://rubygems.org'
source 'http://gems.dev.mas.local'

gem 'rails', '~> 4.2.11'


gem 'actionpack-page_caching', '~> 1.0.2' # Security: needs update
gem 'addressable', '~> 2.1', require: 'addressable/uri'
gem 'akismet', '~> 1.0'
gem 'attr_encrypted', '~> 3.1'
gem 'autoprefixer-rails'
gem 'blind_index', '0.2.0'
gem 'bluecloth', '~> 2.1'
gem 'carrierwave', '~> 0.10.0' # Security: needs update to 1.3.2
gem 'carrierwave-azure'
gem 'ckeditor', git: 'https://github.com/galetahub/ckeditor'
gem 'coderay', '~> 1.1.0'
gem 'coffee-rails', ' ~> 4.0.1'
gem 'compass-rails'
gem 'csslint_ruby'
gem 'dotenv-rails'
gem 'dough-ruby', '~> 5.0', require: 'dough'
gem 'dynamic_form', '~> 1.1.4'
gem "excon", ">= 0.71.0"
gem 'fastimage'
gem 'flickraw-cached'
gem 'fog'
gem 'google-api-client', '0.7.1'
gem 'htmlentities'
gem 'jbuilder'
gem 'jquery-rails', '~> 3.1.0'
gem 'jquery-ui-rails', '~> 5.0.2'
gem 'jshint_ruby'
gem "json", "= 2.4.0"
gem "kaminari", "= 1.2.1"
gem "kramdown", ">= 2.3.0"
gem 'legato', '0.4.0'
gem 'loofah', '= 2.7.0'
gem 'mailjet'
gem 'mini_magick', ">= 4.9.4", require: 'mini_magick'
gem 'newrelic_rpm'
gem 'nokogiri', '< 1.11.0'
gem 'non-stupid-digest-assets'
gem 'oauth2', '1.0.0'
gem 'pg', '~> 0.20.0'
gem 'rack-trailing_slashes'
gem 'rails-html-sanitizer', '= 1.3.0'
gem 'rails-observers', '~> 0.1.2'
gem 'rails-timeago', '~> 2.0'
#gem 'rake', '~> 10.3.2'
gem 'rake', '~> 12.3.3'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'RedCloth', '~> 4.2.8'
gem 'responders', '~> 2.0'
gem 'rails_autolink', '~> 1.1.0'
gem 'rubypants', '~> 0.2.0'
gem 'sass-rails', ' ~> 4.0.3'
gem 'twitter', '~> 6.2.0'
gem 'uglifier'
gem 'unicorn'
gem 'uuidtools', '~> 2.1.1'
gem 'webpurify'#, require: 'web_purify'
gem "websocket-extensions", ">= 0.1.5"
gem 'xmlrpc'


group :build, :test, :development do
  gem 'bowndler', '~> 1.0'
end

group :development, :test do
  gem 'factory_bot', '~> 4.8.0'
  gem 'simplecov', require: false
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rubocop', require: false
  gem 'launchy'
  gem 'poltergeist'
  gem 'foreman'
  gem 'letter_opener'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'byebug'
  gem 'rb-readline'
end

group :test do
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'danger', require: false
  gem 'danger-rubocop', require: false
  gem 'rspec_junit_formatter'
  gem 'site_prism'
  gem 'tzinfo-data'
end

group :production do
  gem 'syslog-logger'
end
