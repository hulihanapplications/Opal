require 'spec_helper'

describe ApplicationController do
  context "as visitor" do
    describe "set_user" do
      pending "returns User.anonymous"          
    end
    
    describe "authenticate_user" do
      it "should redirect to login" do 
        get :authenticate_user
        @response.should redirect_to login_path
      end
    end
  end
  
  context "as admin" do
    before(:each) do
      login_admin
    end 
  end
  
  context "as user" do 
    before(:each) do
      login_user
    end       
  end
end
