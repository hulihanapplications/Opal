#!/usr/bin/ruby

require 'rubygems'
require 'fcgi'

ENV['RAILS_ENV'] ||= 'production' 

# Load GEM_PATH and GEM_HOME
gem_home_path = File.expand_path('../config/gem_home', File.dirname(__FILE__))
raise Errno::ENOENT, gem_home_path unless File.exists?(gem_home_path)
GEM_HOME = File.read(gem_home_path)
ENV['GEM_HOME'] ||= GEM_HOME

require 'rubygems'
Gem.clear_paths

require File.join(File.dirname(__FILE__), '../config/environment')

class Rack::PathInfoRewriter
 def initialize(app)
   @app = app
 end

 def call(env)
   env.delete('SCRIPT_NAME')
   parts = env['REQUEST_URI'].split('?')
   env['PATH_INFO'] = parts[0]
   env['QUERY_STRING'] = parts[1].to_s
   @app.call(env)
 end
end

Rack::Handler::FastCGI.run  Rack::PathInfoRewriter.new(Opal::Application)
