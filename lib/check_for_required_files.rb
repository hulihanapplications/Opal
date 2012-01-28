# Check for Required Files before Rails is Loaded
require 'fileutils'

rails_root = File.join(File.dirname(__FILE__), "..")
if !File.exists?(File.join(rails_root, "config", "database.yml")) && File.exists?(File.join(rails_root, "config", "database.yml.default")) # check for database.yml
  FileUtils.cp(File.join(rails_root, "config", "database.yml.default"), File.join(rails_root, "config", "database.yml"))
  puts File.join("config", "database.yml.default") + " -> " + File.join("config", "database.yml")
end 
