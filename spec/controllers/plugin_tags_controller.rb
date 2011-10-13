require 'spec_helper'

describe PluginTagsController do  
  render_views
  
  context "as user" do
    before(:each) do
      login_user
      @record = Factory(:item, :user => @controller.set_user)
    end      
    
    describe "create" do 
      it "should work" do
        expect{
          post(:create, {:record_id => @record.id, :record_class => @record.class.name, :plugin_tag => Factory.attributes_for(:plugin_tag)})
        }.to change(PluginTag, :count).by(+1)
        flash[:success].should_not be_nil
        assigns[:tag].destroy # clean up
      end    
    end
    
    describe "destroy" do 
      it "should reduce count and return success" do
      @tag = Factory(:plugin_tag, :record => @record)
        expect{
          post(:delete, {:id => @record.id, :tag_id => @tag.id})
        }.to change(PluginTag, :count).by(-1) 
        flash[:success].should_not be_nil
      end 
    end
  end
  
  context "as visitor" do
    describe "download" do
      @tag = Factory(:plugin_tag)
      get(download_path(:tag_id => @tag.id, :id => @tag.record.id))
      response.code.should eq("200")
    end    
  end
end
