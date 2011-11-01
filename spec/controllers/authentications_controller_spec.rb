require 'spec_helper'

describe AuthenticationsController do  
  render_views
  
  describe "as admin" do
    before(:each) do
      login_admin
    end 
    
    describe "index" do
      it "returns 200" do
        get :index
        response.code.should eq("200")
      end      
    end


  end
  
  context "as user" do
    before(:each) do
      login_user
    end
    
    describe "create" do
      pending "logs them in automatically if the authentication is already associated with the user's account" 
      pending "adds authentication to user's account if they're logged in" 
      pending "saves authentication information, then redirects the to registration form" 
        
  
=begin
      it "increments count" do
        expect{
          post(:create, {:authentication => Factory.attributes_for(:user)})
        }.to change(Authentication, :count).by(+1)
        flash[:success].should_not be_nil
        @response.should redirect_to(users_path)
      end      
=end
    end
    
    describe "destroy" do
      it "decrements count" do
        authentication = Factory(:authentication, :user => current_user)
        expect{
          post(:destroy, {:id => authentication.id})
        }.to change(Authentication, :count).by(-1)
        flash[:success].should_not be_nil
        @response.should redirect_to(authentications_path)
      end      
    end   
  end 
  
  context "as visitor" do
    pending "failure"     

    describe "create" do      
      pending "saves authentication/provider information, then redirects the to registration form"      
    end    
  end 
end
