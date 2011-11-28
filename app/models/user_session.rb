class UserSession < Authlogic::Session::Base
  # specify configuration here, such as:
  # logout_on_timeout true
  # ...many more options in the documentation
  
  # Custom Configuration
  find_by_login_method :lookup # User lookup method
  verify_password_method :password? # User password verification method
  
  def to_key # rails3 fix
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end
end
