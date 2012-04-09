source "http://rubygems.org/"
gem "rails", "3.2.2"#, :git => "http://github.com/rails/rails"
gem "opal", :path => File.expand_path("#{File.dirname(__FILE__)}/vendor/gems")
gem "russian", :path => File.expand_path("#{File.dirname(__FILE__)}/vendor/gems/russian")  #, :git => "git://github.com/MrHant/russian.git" # Gem specific for "ru" locale
gem "rmagick", "~>2.12.2"
gem "i18n"
gem "rubyzip"
gem "ya2yaml" 
gem "authlogic", "3.1.0"
gem "ancestry"
gem "will_paginate", ">= 3.0.pre2"
gem "omniauth"
gem "omniauth-twitter"
gem "omniauth-facebook"
gem "omniauth-google"
gem "omniauth-oauth2"
gem "carrierwave"
gem "fog" # for s3 and rackspace cloud files support
gem "make_voteable", :path => File.expand_path("#{File.dirname(__FILE__)}/vendor/gems/make_voteable-106adecfad30")#, :git => "git://github.com/medihack/make_voteable"
gem "humanizer", "=2.4.3"
gem "cregexp"
gem 'dynamic_form'
gem 'thin'
gem "friendly_id", "~> 4.0.1"

group :development do
  gem 'sqlite3'
end

group :production do
  gem "mysql2"
end

group :assets do
  gem 'jquery-rails'
  gem 'sass-rails'
  gem "authbuttons-rails"
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'therubyracer'
  gem 'compass-rails'
end

group :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "spork"
end 
