# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

module RSpec
  module Core    
   class ExampleGroup
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
  end 
end