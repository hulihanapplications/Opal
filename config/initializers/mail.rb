# Load Mail Settings from config/email.yml
Opal::Application.configure do
  config.action_mailer.raise_delivery_errors = false # report email errors?...usually overriden by config/environments/[environment]
    
  if RAILS_ENV != 'test'
    if File.exists?("#{RAILS_ROOT}/config/email.yml")
      config.action_mailer.delivery_method = :smtp
      email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
      config.action_mailer.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
    else # no mail config file found
      config.action_mailer.delivery_method = :sendmail  # attempt to use use sendmail
    end
  end
end

