require 'spec_helper'

describe usersController do  
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

    describe "new" do
      it "returns 200" do
        get :new
        response.code.should eq("200")
      end      
    end
    
    describe "create" do
      it "increments count" do
        expect{
          post(:create, {:user => Factory.attributes_for(:user)})
        }.to change(User, :count).by(+1)
        flash[:success].should_not be_nil
        @response.should redirect_to(users_path)
      end      
    end
    
    describe "destroy" do
      it "decrements count" do
        user = Factory(:user)
        expect{
          post(:delete, {:id => user.id})
        }.to change(User, :count).by(-1)
        flash[:success].should_not be_nil
        @response.should redirect_to(users_path)
      end      
    end   

    describe "edit" do
      it "returns 200" do
        user = Factory(:user)       
        get(:edit, {:id => user.id})
        response.code.should eq("200")
      end      
    end
    
    describe "update" do
      it "saves changes" do
        user = Factory(:user)       
        post(:update, {:id => user.id, :user => {:name => "New Name"}})
        flash[:success].should_not be_nil
        user.find(user.id).name.should == "New Name" 
      end      
    end
    
    pending "toggle_user_disabled"
    pending "toggle_user_verified"
    pending "send_verification_email"
  end
  
  context "as user" do
    before(:each) do
      login_user
      #@user = Factory(:item, :user => @controller.set_user)
    end
    
    pending "change_avatar"
    pending "change_password"
    pending "verification_required"
  end 
  
  context "as visitor" do
    pending "show" 
  end 
end
