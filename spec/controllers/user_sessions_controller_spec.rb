require 'spec_helper'

describe UserSessionsController do  
  render_views
 
  context "as visitor" do  
    before(:each) do
      login_anonymous 
      
      @password = "somepassword"
      @user = Factory(:user, :password => @password)
    end 
    
    describe "new" do
      it "returns 200" do
        get :new
        response.code.should eq("200")
      end      
    end
    
    describe "create" do      
      it "works when logging in with email" do
        post(:create, {:user_session => {:username => @user.email, :password => @password}})
        flash[:success].should_not be_nil         
        response.should redirect_to user_home_path
      end   

      it "works when logging in with username" do
        post(:create, {:user_session => {:username => @user.username, :password => @password}})
        flash[:success].should_not be_nil         
        response.should redirect_to user_home_path
      end          
      
      it "fails when logging in with the wrong password" do
        post(:create, {:user_session => {:username => @user.username, :password => "wrongpassword"}})
        flash[:failure].should_not be_nil         
        response.should render_template("new")
      end       
    end
    
    describe "destroy" do
      it "successfully logs out the user" do
        post(:create, {:user_session => {:username => @user.username, :password => @password}})
        post(:destroy)
        UserSession.find.should be_nil  
        flash[:success].should_not be_nil         
        response.should redirect_to root_path              
      end
    end
  end
end
