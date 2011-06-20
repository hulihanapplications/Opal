ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  def login_as_admin
    #puts "Logging in..."
    @logged_in_user = User.find_by_username("admin")
    if @logged_in_user
      
    else
      puts "Admin Not Found!" unless @logged_in_user
    end
  end
end
