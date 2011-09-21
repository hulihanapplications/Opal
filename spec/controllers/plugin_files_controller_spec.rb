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
          post(:create, {:id => @item.id, :plugin_file => Factory.attributes_for(:plugin_file)})
        }.to change(Pluginfile, :count).by(+1)
        flash[:success].should_not be_nil
        assigns[:file].destroy # clean up
      end    
    end
    
    describe "destroy" do 
      it "should reduce count and return success" do
      @file = Factory(:plugin_file, :item => @item)
        expect{
          post(:delete, {:id => @item.id, :file_id => @file.id})
        }.to change(Pluginfile, :count).by(-1) 
        flash[:success].should_not be_nil
      end 
    end
  end
  
  context "as visitor" do
    describe "download" do
      @file = Factory(:plugin_file)
      get(download_path(:file_id => @file.id, :id => @file.item.id))
      response.code.should eq("200")
    end    
  end
end
