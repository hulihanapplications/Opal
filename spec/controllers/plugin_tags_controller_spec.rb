require 'spec_helper'

describe PluginTagsController do  
  render_views
  
  context "as user" do
    before(:each) do
      login_user
      @record = FactoryGirl.create(:item, :user => current_user)
    end      
    
    describe "create" do 
      it "should work" do
        expect{
          post(:create, {:record_id => @record.id, :record_type => @record.class.name, :plugin_tag => FactoryGirl.attributes_for(:plugin_tag)})
          flash[:success].should_not be_nil
        }.to change(PluginTag, :count).by(+1)        
      end    
    end
    
    describe "destroy" do 
      it "should reduce count and return success" do
      @tag = FactoryGirl.create(:plugin_tag, :record => @record)
        expect{
          post(:delete, {:record_id => @tag.id, :record_type => @tag.class.name})
          flash[:success].should_not be_nil
        }.to change(PluginTag, :count).by(-1) 
      end 
    end
  end
end
