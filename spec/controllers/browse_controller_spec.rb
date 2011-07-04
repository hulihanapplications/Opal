require 'spec_helper'

describe BrowseController do
  render_views
  
  describe "GET index" do
    it "has a 200 status code" do
      get :index
      @response.code.should eq("200")
    end
    
    it "has a 200 status code with new items homepage" do
      Setting.find_by_name("homepage_type").update_attribute(:value, "new_items")    
      get :index
      @response.code.should eq("200")
    end  
     
    it "has a 200 status code with categories homepage" do
      Setting.find_by_name("homepage_type").update_attribute(:value, "categories")    
      get :index
      @response.code.should eq("200")
    end      

    it "has a 200 status code with no homepage type" do
      Setting.find_by_name("homepage_type").update_attribute(:value, "none")    
      get :index
      @response.code.should eq("200")
    end      
  end
end
