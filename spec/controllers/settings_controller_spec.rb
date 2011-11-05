require 'spec_helper'

describe SettingsController do  
  render_views
  
  context "as admin" do
    before(:each) do
      login_admin
    end 

    describe :index do
      it "GET index returns 200" do
        get :index
        response.code.should eq("200")
      end          
    end

    describe :new_change_logo do
      it "returns 200" do
        get :new_change_logo
        response.code.should eq("200")
      end    
    end
    
    describe :change_logo do 
      pending :it_works
    end

    describe :delete_logo do 
      pending :it_works
    end  
    
    describe :themes do
      it "returns 200" do
        get :themes
        response.code.should eq("200")
      end    
    end
    
    describe :new_theme_install do
      it "returns 200" do
        get :new_theme_install
        response.code.should eq("200")
      end    
    end  
    
    describe :install_theme do
      pending :it_works
    end        

    describe :delete_theme do
      pending :it_works
    end           
  end
end
