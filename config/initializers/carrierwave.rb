# Configure Carrierwave globally. Anything you see here can be applied on a per-uploader basis.
CarrierWave.configure do |config|
  config_file = Rails.root.join("config", "upload.yml")
  if File.exists?(config_file)
    yaml_data = YAML::load(File.open(config_file))
    config_hash = yaml_data.is_a?(Hash) ? (!yaml_data[:upload].nil? ? yaml_data[:upload] : Hash.new) : Hash.new
  else
    config_hash = Hash.new
  end
  
  # Set Defaults
  config_hash[:storage]     ||= :file
  config_hash[:permissions] ||= 0644 

  config.storage config_hash[:storage]  
  config.permissions config_hash[:permissions]  
  
  if config_hash[:storage].to_s == "fog"
    config.fog_credentials = config_hash[:fog_credentials]
    config.fog_directory = config_hash[:fog_directory]
    config.fog_host = config_hash[:fog_host]
    config.fog_public = config_hash[:fog_public]
    config.fog_attributes = config_hash[:fog_attributes]                 
  end  

  config.root config_hash[:root] if config_hash[:root]
end