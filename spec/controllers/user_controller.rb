require 'spec_helper'

describe UserController do  
  render_views
 
  context "as user" do  
    before(:each) do
      login_user 
    end 
    
    describe "index" do
      it "GET index returns 200" do
        get :index
        response.code.should eq("200")
      end      
    end
  end
  
  context "as visitor" do 
    describe "register" do 
      it "GET index returns 200" do
        get :register
        response.code.should eq("200")
      end         
    end
  end
end
