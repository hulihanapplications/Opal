if Rails.env != 'test'  
  config = Authentication.config
  if config && !config.empty?
    Rails.application.config.middleware.use OmniAuth::Builder do        
      config["providers"].each do |name, credentials|
        provider name.to_sym, credentials["key"], credentials["secret"], {:client_options => config[:client_options]}       
      end
    end
  end
end

