# Load Mail Settings from config/email.yml
ActionMailer::Base.raise_delivery_errors = false # don't report actionmailer errors...usually overriden by config/environments/[environment]

if RAILS_ENV != 'test'
  if File.exists?("#{RAILS_ROOT}/config/email.yml")
    email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
    ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
  end
end

