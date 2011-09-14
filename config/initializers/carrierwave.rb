CarrierWave.configure do |config|
  #config.permissions = 0755
  config.storage = :file
  #config.root = Rails.root # set base location of stored files 
  #config.cache_dir = "#{Rails.root}/tmp/uploads"
  #config.delete_original_file = true
end