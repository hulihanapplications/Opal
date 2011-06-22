require 'spec_helper'

describe AdminController do  
  render_views
  
  describe "as visitor" do
    it "GET index redirects to login" do
      get :index
      response.code.should redirect_to(login_path)
    end
  end
  
  describe "as admin" do
    before(:each) do
      login_admin
    end 

    it "GET index returns 200" do
      get :index
      response.code.should eq("200")
    end    
  end
end
