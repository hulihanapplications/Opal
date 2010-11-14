# Copyright (c) 2008 [Sur http://expressica.com]

require 'fileutils'

namespace :simple_captcha do
  
  def generate_migration
    puts "==============================================================================="
    puts "ruby script/generate migration create_simple_captcha_data"
    puts %x{ruby script/generate migration create_simple_captcha_data}
    puts "================================DONE==========================================="
  end
  
  def migration_source_file
    @rails == 'old' ?
    File.join(File.dirname(__FILE__), "../assets", "migrate", "create_simple_captcha_data_less_than_2.0.rb") :
    File.join(File.dirname(__FILE__), "../assets", "migrate", "create_simple_captcha_data.rb")
  end

  def write_migration_content
    copy_to_path = File.join(RAILS_ROOT, "db", "migrate")
    migration_filename = 
      Dir.entries(copy_to_path).collect do |file|
        number, *name = file.split("_")
        file if name.join("_") == "create_simple_captcha_data.rb"
      end.compact.first
    migration_file = File.join(copy_to_path, migration_filename)
    File.open(migration_file, "wb"){|f| f.write(File.read(migration_source_file))}
  end

  def copy_view_file
    puts "Copying SimpleCaptcha view file."
    mkdir(File.join(RAILS_ROOT, "app/views/simple_captcha")) unless File.exist?(File.join(RAILS_ROOT, "app/views/simple_captcha"))
    view_file = @rails == 'old' ? '_simple_captcha.rhtml' : '_simple_captcha.erb'
    FileUtils.cp_r(
      File.join(File.dirname(__FILE__), "../assets/views/simple_captcha/_simple_captcha.erb"),
      File.join(RAILS_ROOT, "app/views/simple_captcha/", view_file)
    )
    puts "================================DONE==========================================="
  end
  
  def do_setup
    begin
      puts "STEP 1"
      generate_migration
      write_migration_content
      copy_view_file
      puts "Followup Steps"
      puts "STEP 2 -- run the task 'rake db:migrate'"
      puts "STEP 3 -- edit the file config/routes.rb to add the route \"map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'\""
    rescue StandardError => e
      p e
    end
  end
  
  desc "Set up the plugin SimpleCaptcha for rails < 2.0"
  task :setup_old do
    @rails = 'old'
    do_setup
  end
  
  desc "Set up the plugin SimpleCaptcha for rails >= 2.0"
  task :setup do
    do_setup
  end
  
end
