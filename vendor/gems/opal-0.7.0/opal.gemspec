Gem::Specification.new do |s|
  s.name = "opal"
  s.version = "0.7.0"
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
  s.has_rdoc = false
  #s.add_dependency "rmagick", ">=2.12.2"
end
