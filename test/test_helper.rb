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
    post "/user_sessions/create", :user => {:username => "admin", :password => "admin"} 
    puts assisgs(:logged_in_user).inspect
  end
  
  def wrap_with_controller( new_controller = UserSessionsController )
    old_controller = @controller # Store current controller temporarily
    @controller = new_controller.new # set current controller as something else 
    yield
    @controller = old_controller # switch back
  end
  
  def login_admin
    wrap_with_controller do
      post(:create, {:user_session => {:username => 'admin', :password => 'admin'}})
    end
  end
  
  def login_regular
    wrap_with_controller do
      post(:create, {:user_session => {:username => 'test', :password => 'test'}})
    end
  end  
end
