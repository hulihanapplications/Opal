require 'spec_helper'

describe LogsController do  
  render_views
  
  context "as admin" do
    before(:each) do
      login_admin
    end 

    it "GET index returns 200" do
      get :index
      response.code.should eq("200")
    end  
    
    describe "for_me" do
      it "returns 200" do
        get :for_me
        response.code.should eq("200")
      end      
    end

    describe "for_item" do
      it "returns 200" do
        get :for_item, {:id => Factory(:item).id}
        response.code.should eq("200")
      end      
    end
    
    describe "for_user" do
    end
  end
end
