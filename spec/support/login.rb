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
        @controller.stub!(:current_user).and_return(Factory(:admin))
        wrap_with_controller do
          #post(:create, {:user_session => {:username => Factory.attributes_for(:admin)[:username], :password => Factory.attributes_for(:admin)[:password]}})                   
          #raise "Failed Logging in as #{Factory.attributes_for(:admin)[:username]}" if flash[:success].nil?
        end
      end
      
      def login_user
        @controller.stub!(:current_user).and_return(Factory(:user))
        wrap_with_controller do
          #post(:create, {:user_session => {:username => Factory.attributes_for(:user)[:username], :password => Factory.attributes_for(:user)[:password]}})
          #raise "Failed Logging in as #{Factory.attributes_for(:user)[:username]}" if flash[:success].nil?          
        end
      end  
    end 
  end 
end