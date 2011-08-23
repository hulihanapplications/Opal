require 'spec_helper'

describe PluginDiscussionsController do  
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
   	  @discussion = Factory(:plugin_discussion, :item => @item)      
    end 
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, {:id => @item.id, :discussion => Factory.attributes_for(:plugin_discussion)})
        }.to change(PluginDiscussion, :count).by(+1)
        flash[:success].should_not be_nil
      end        
    end
 
   	describe "destroy" do 
   	  it "should reduce count and return success" do
        expect{
          post(:delete, {:id => @item.id, :discussion_id => @discussion.id})
        }.to change(PluginDiscussion, :count).by(-1) 
        flash[:success].should_not be_nil
   	  end	
   	end
  
  	pending "create_post"
  	pending "delete_post"   	   
  end
  
  context "as visitor" do
	pending "view"
  	pending "rss"
  end

end
