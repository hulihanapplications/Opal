# Load Mail Settings from config/email.yml
Rails.application.class.configure do 
  config_file = Rails.root.join("config/email.yml")
  
  if Rails.env != 'test'
    if File.exists?(config_file)
      config.action_mailer.delivery_method = :smtp
      email_settings = YAML::load(File.open(config_file))
      config.action_mailer.smtp_settings = email_settings[Rails.env] unless email_settings[Rails.env].nil?
      # Load host from config file if specified
      config.action_mailer.default_url_options ||= {:host => email_settings[Rails.env][:host]} if email_settings[Rails.env][:host]
    else # no mail config file found
      config.action_mailer.delivery_method = :sendmail if File.exists?(Emailer.sendmail_settings[:location]) # attempt to use use sendmail
      config.action_mailer.default_url_options ||=  {:host => "localhost"} # set actionmailer default host       
    end
  end
end