require 'spec_helper'

describe GroupsController do  
  render_views
  
  context "as admin" do
    before(:each) do
      login_admin
    end 

    it "GET index returns 200" do
      get :index
      response.code.should eq("200")
    end  
    
    describe "new" do
      it "returns 200" do
        get :new
        response.code.should eq("200")
      end      
    end

    describe "edit" do
      it "returns 200" do
        get :edit, {:id => Factory(:group).id}
        response.code.should eq("200")
      end      
    end
    
    describe "create" do
      it "adds a group" do
        expect{
          post(:create, {:group => Factory.attributes_for(:group)})
        }.to change(Group, :count).by(+1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "index")
      end      
    end
    
    describe "destroy" do
      it "destroys a group" do
        group = Factory(:group)
        expect{
          post(:delete, {:id => group.id})
        }.to change(Group, :count).by(-1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "index")
      end      
    end   
    
    describe "update" do
      it "saves changes" do
        group = Factory(:group)       
        post(:update, {:id => group.id, :group => {:name => "New Name"}})
        flash[:success].should_not be_nil
        assigns[:group].name.should == "New Name" 
      end      
    end
    
    pending "update_plugin_permissions"
  end
end
