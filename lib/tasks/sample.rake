namespace :db do
  desc "Install sample data"
  task :sample => :environment do
    sample_path = File.join(File.dirname(__FILE__), '..', '..', 'db', 'sample')
    require sample_path
  end 
end 