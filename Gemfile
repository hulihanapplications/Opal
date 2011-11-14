source "http://rubygems.org/"

gem "rails", "=3.1.1"#, :git => "http://github.com/rails/rails"
gem "opal", :path => File.expand_path("#{File.dirname(__FILE__)}/vendor/gems")
gem "russian", :path => File.expand_path("#{File.dirname(__FILE__)}/vendor/gems/russian")  #, :git => "git://github.com/MrHant/russian.git" # Gem specific for "ru" locale
gem "rmagick", "~>2.12.2"
gem "i18n"
gem "rubyzip"
gem "ya2yaml" 
gem "authlogic", ">=3.0.3"
gem "ancestry"
gem "will_paginate", ">= 3.0.pre2"
gem "omniauth"
gem "authbuttons-rails"
gem "carrierwave"
gem "fog" # for s3 and rackspace cloud files support
#gem 'jquery-rails'
gem "make_voteable", :path => File.expand_path("#{File.dirname(__FILE__)}/vendor/gems/make_voteable-106adecfad30")#, :git => "git://github.com/medihack/make_voteable"
gem "humanizer", "=2.4.3"

# Database Gems
#gem "mysql2"
gem 'sqlite3'

group :development do
end

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
  gem 'therubyracer'
end

group :test do
 gem "rspec-rails"
 gem "factory_girl_rails"
end 
