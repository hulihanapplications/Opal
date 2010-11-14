app_name = "Opal"
namespace app_name.downcase.to_sym do

  desc "Install #{app_name} - Database, Default Data, and optional Example Data"
  task :install => :environment do
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
    puts "\n\n#{app_name} Installed successfully!"    
    # Log Install
    Log.create(:log => "#{app_name} Installed!", :log_type => "system")    
  end

  desc 'Uninstall #{app_name}'
  task :uninstall => :environment do
    ENV['VERSION']= '0'
    Rake::Task['db:migrate'].invoke
  end

  desc "Update #{app_name}"
  task :install => :environment do
    Rake::Task["db:migrate"].invoke
  end

  desc "Reset #{app_name}"
  task :reset => :environment do
    Rake::Task['opal:uninstall'].invoke
    ENV.delete 'VERSION' # clear version 
    Rake::Task['db:migrate'].reenable
    Rake::Task['opal:install'].invoke
  end
end



