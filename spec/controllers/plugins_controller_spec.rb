require 'spec_helper'

describe PluginsController do  
  render_views
  
  describe "as admin" do
    before(:each) do
      login_admin
    end 

    describe :index do 
      it "should load properly" do
        get :settings, {:id => Plugin.first}
        response.code.should eq("200")
      end 
    end  

    describe :settings do 
      it "should load properly" do
        get :settings, {:id => Plugin.first}
        response.code.should eq("200")
      end 
    end        
  end
end
