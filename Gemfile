source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '~> 5.0.0'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'kaminari'

gem 'slim'
gem 'govuk_frontend_toolkit'
gem 'govuk_template'
gem 'govuk_elements_rails'

gem 'jquery-rails'
gem 'jbuilder', '~> 2.5'

gem 'rack-proxy'

gem 'rest-client', '>= 2.0.0'
gem 'openregister-ruby', git: 'https://github.com/openregister/openregister-ruby'
gem 'nokogiri'

gem 'dalli'

gem 'mongoid', '= 6.0.0.beta'
# gem 'mongoid-enum'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5.1'
  gem 'guard-rspec', '~> 4.7.3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rb-fsevent', '<= 0.9.4', require: RUBY_PLATFORM[/darwin/i].to_s.size > 0
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
