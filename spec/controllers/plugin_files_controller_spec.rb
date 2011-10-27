require 'spec_helper'

describe PluginFilesController do  
  render_views
    
  describe "as admin" do
    before(:each) do
      login_admin
    end 
  end
  
  context "as user" do
    before(:each) do
      login_user
      @item = Factory(:item, :user => @controller.set_user)
    end      
    
    describe "create" do 
      it "should work with local file" do
        expect{
          post(:create, {:record_type => @item.class.name, :record_id => @item.id, :plugin_file => Factory.attributes_for(:plugin_file)})
        }.to change(PluginFile, :count).by(+1)
        flash[:success].should_not be_nil
        assigns[:file].destroy # clean up
      end    
    end
    
    describe "destroy" do 
      it "should reduce count and return success" do
      @file = Factory(:plugin_file, :record => @item)
        expect{
          post(:delete, {:record_type => @file.class.name, :record_id => @file.id})
          flash[:success].should_not be_nil
        }.to change(PluginFile, :count).by(-1) 
      end 
    end
  end
  
  context "as anonymous" do
    before(:each) do
      login_anonymous  
    end      
    
    describe "download" do
      it "should return 200" do
        @file = Factory(:plugin_file)
        get(:download, {:record_type => @file.class.name, :record_id => @file.id})
        response.code.should eq("200")
      end 
    end    
  end
end
