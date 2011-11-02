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
    config.fog_attributes = config_hash[:fog_attributes] unless config_hash[:fog_attributes].nil?              
  end  

  config.root config_hash[:root] if config_hash[:root]
end

# Extend CarrierWave Functionality
module CarrierWave
  module Uploader
    module RemoveDirectory
      # delete files and directory, since remove only deletes the file
      def remove_directory
        FileUtils.rm_rf(File.dirname(path)) if !path.blank? && File.exists?(File.dirname(path)) # remove CarrierWave store dir, must be empty to work
      end      
    end
    
    module RemoveTmp
      # store! nil's the cache_id after it finishes so we need to remember it for deletion
      def remember_cache_id(new_file)
        @cache_id_was = cache_id
      end
    
      def delete_tmp_dir(new_file)
        # make sure we don't delete other things accidentally by checking the name pattern
        if @cache_id_was.present? && @cache_id_was =~ /\A[\d]{8}\-[\d]{4}\-[\d]+\-[\d]{4}\z/
          FileUtils.rm_rf(File.join(cache_dir, @cache_id_was))
        end
      end      
    end
  end
  
  module RMagick
    module Advanced
      
    end
  end
end

CarrierWave::Uploader::Base.send(:include, CarrierWave::Uploader::RemoveDirectory)
CarrierWave::Uploader::Base.send(:include, CarrierWave::Uploader::RemoveTmp)
# Delete Cached Stuff after file has been stored
CarrierWave::Uploader::Base.send(:before, :store, :remember_cache_id) 
CarrierWave::Uploader::Base.send(:after, :store, :delete_tmp_dir) 
# Make all Uploaders remove uploaded file directory  
CarrierWave::Uploader::Base.send(:before, :remove, :remove_directory) 
