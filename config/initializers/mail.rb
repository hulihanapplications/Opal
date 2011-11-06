# Load Mail Settings from config/email.yml
Rails.application.class.configure do 
  config.action_mailer.raise_delivery_errors = false # report email errors?...usually overriden by config/environments/[environment]
    
  if Rails.env != 'test'
    if File.exists?("#{Rails.root.to_s}/config/email.yml")
      config.action_mailer.delivery_method = :smtp
      email_settings = YAML::load(File.open("#{Rails.root.to_s}/config/email.yml"))
      config.action_mailer.smtp_settings = email_settings[Rails.env] unless email_settings[Rails.env].nil?
    else # no mail config file found
      config.action_mailer.delivery_method = :sendmail if File.exists?(Emailer.sendmail_settings[:location]) # attempt to use use sendmail
    end
  end

  config.action_mailer.default_url_options ||=  {:host => "localhost"} # set actionmailer default host 
end


