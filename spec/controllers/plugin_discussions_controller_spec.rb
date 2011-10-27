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
      @record = Factory(:item, :user => @controller.set_user)
   	  @discussion = Factory(:plugin_discussion, :record => @record)      
    end 
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, {:record_type => @record.class.name, :record_id => @record.id, :discussion => Factory.attributes_for(:plugin_discussion)})
          flash[:success].should_not be_nil
        }.to change(PluginDiscussion, :count).by(+1)
      end        
    end
 
   	describe "destroy" do 
   	  it "should reduce count and return success" do
        expect{
          post(:delete, {:record_id =>  @discussion.id, :record_type => @discussion.class.name})
          flash[:success].should_not be_nil
        }.to change(PluginDiscussion, :count).by(-1) 
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
