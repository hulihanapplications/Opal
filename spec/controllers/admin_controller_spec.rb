require 'spec_helper'

describe AdminController do  
  describe "GET index" do
    it "redirects when visitor makes request" do
      get :index
      response.code.should eq("302")
    end
    
    it("gives a 200 response when visited as an admin", :as_admin => true) do
      #controller.stub!(:authenticate_admin).and_return(nil)
      #controller.stub!(:authenticate_user).and_return(nil)     
      #@logged_in_user = User.find_by_username("admin")      
      get :index
      response.code.should eq("200")
    end    
  end
end
