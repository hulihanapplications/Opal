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
        configure_request               
        @controller.stub!(:current_user).and_return(FactoryGirl.create(:admin))
        wrap_with_controller do
          #post(:create, {:user_session => {:username => FactoryGirl.attributes_for(:admin)[:username], :password => FactoryGirl.attributes_for(:admin)[:password]}})                   
          #raise "Failed Logging in as #{FactoryGirl.attributes_for(:admin)[:username]}" if flash[:success].nil?
        end
      end
      
      def login_user
        configure_request       
        @controller.stub!(:current_user).and_return(FactoryGirl.create(:user))
        wrap_with_controller do
          #post(:create, {:user_session => {:username => FactoryGirl.attributes_for(:user)[:username], :password => FactoryGirl.attributes_for(:user)[:password]}})
          #raise "Failed Logging in as #{FactoryGirl.attributes_for(:user)[:username]}" if flash[:success].nil?          
        end
      end
      
      def login_anonymous
        configure_request     
      end
      
      def current_user
        @controller.set_user
      end  
      
      def stub_captcha
        @controller.stub!(:human?).and_return(true)  
      end
    end 
  end 
end