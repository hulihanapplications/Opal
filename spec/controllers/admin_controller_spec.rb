require 'spec_helper'

describe AdminController do  
  describe "as visitor" do
    it "GET index redirects" do
      get :index
      response.code.should eq("302")
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
