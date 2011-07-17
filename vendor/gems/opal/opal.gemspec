#load relative lib
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "opal/version"

Gem::Specification.new do |s|
  s.name = "opal"
  s.version = Opal::VERSION
  s.author = "Hulihan Applications"
  s.email = "dave@hulihanapplications.com"
  s.homepage = "http://www.hulihanapplications.com/projects/opal"
  s.platform = Gem::Platform::RUBY
  s.summary = "Opal is an Item Management System written in Ruby on Rails"
  s.files = [
  	"init.rb", 
  	"setup.rb", 
  	"opal.gemspec", 
  	"{app,config,spec,lib,bin,doc,examples}/**/*"
  	].map{|p| Dir[p]}.flatten
  s.bindir = "bin"
  #s.executables = [""]
  s.require_path = "lib"
  #s.autorequire = "opal"
  #s.add_dependency "rmagick", ">=2.12.2"
end
