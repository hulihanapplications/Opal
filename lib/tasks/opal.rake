require File.expand_path(File.join("..", "..", "..", "config", "environment"), __FILE__) # load rails environment & initalizers
namespace I18n.t("name").downcase.to_sym do

  # TODO: Reload Rails env for every DB-Related task

  desc "Install #{I18n.t("name")} - Database, Default Data, and optional Example Data"
  task :install => :environment do  
    dep_msg = "rake opal:install is no longer used. Please use the rake tasks found in the README instead."      
    ActiveSupport::Deprecation.warn(dep_msg)
    puts dep_msg    
    #ENV["PROMPTS"] ||= "TRUE"    
    #Rake::Task["db:migrate"].invoke
    #Rake::Task["db:seed"].invoke     
  end

  desc 'Uninstall #{I18n.t("name")}'
  task :uninstall => :environment do
    dep_msg = "rake opal:uninstall is no longer used. Please use the rake tasks found in the README instead."      
    ActiveSupport::Deprecation.warn(dep_msg)
    puts dep_msg    
    #ENV["PROMPTS"] ||= "TRUE"    
    #ENV['VERSION'] = '0'
    #Rake::Task['db:migrate'].invoke
    #item_name_file = File.join(Rails.root.to_s, "config", "locales", "item.yml") 
    #if File.exists?(item_name_file)
    #  File.delete(item_name_file) # delete item.yml if it exists
    #  I18n.reload! # reload I18n any time we delete a translation file
    #end
  end

  desc "Update #{I18n.t("name")}"
  task :update => :environment do
    ENV["PROMPTS"] ||= "TRUE"    
    Rake::Task["db:migrate"].invoke
  end
  	
  desc "Reset #{I18n.t("name")}, To bypass prompts, type: rake opal:reset PROMPTS=FALSE"
  task :reset => :environment do |task, args|
    dep_msg = "rake opal:reset is no longer used. Please use the rake tasks found in the README instead."      
    ActiveSupport::Deprecation.warn(dep_msg)
    puts dep_msg      
  end
end



