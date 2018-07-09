# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.1'

gem 'bootsnap', '1.3', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'pg', '~> 1.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails', '~> 3.7'
  gem 'rubocop', '~> 0.58.0'
  gem 'rubocop-rspec', '~> 1.27.0'
end

group :development do
  gem 'listen', '~> 3.1.5'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
