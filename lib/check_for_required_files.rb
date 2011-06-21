# Check for Required Files before Rails is Loaded
require 'fileutils'

rails_root = File.join(File.dirname(__FILE__), "..")
if !File.exists?(File.join(rails_root, "Gemfile")) && File.exists?(File.join(rails_root, "Gemfile.default")) # check for Gemfile
  FileUtils.cp(File.join(rails_root, "Gemfile.default"), File.join(rails_root, "Gemfile"))
  puts File.join("Gemfile.default") + " -> " + File.join("Gemfile")
end   

if !File.exists?(File.join(rails_root, "config", "database.yml")) && File.exists?(File.join(rails_root, "config", "database.yml.default")) # check for database.yml
  FileUtils.cp(File.join(rails_root, "config", "database.yml.default"), File.join(rails_root, "config", "database.yml"))
  puts File.join("config", "database.yml.default") + " -> " + File.join("config", "database.yml")
end 

if !File.exists?(File.join(rails_root, "config", "environment.rb")) && File.exists?(File.join(rails_root, "config", "environment.rb.default")) # check for environment.rb
  FileUtils.cp(File.join(rails_root, "config", "environment.rb.default"), File.join(rails_root, "config", "environment.rb"))
  puts File.join("config", "environment.rb.default") + " -> " + File.join("config", "environment.rb")
end  