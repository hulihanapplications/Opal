require 'spec_helper'

describe PluginController do  
  render_views
  
  describe "as admin" do
    before(:each) do
      login_admin
    end 
  end
  
  context "as user" do
    before(:each) do
      login_user
      @record = Factory(:plugin_comment, :record => Factory(:item, :user => @controller.set_user))      
    end 
        
    describe :vote do 
      it "upvote should work" do
        previous_up_votes = @record.up_votes
        xhr :post, :vote, {:record_id => @record.id, :record_type => @record.class.name, :controller => "plugin", :direction => "up"}, :format => :js
        assigns[:record].up_votes.should == previous_up_votes + 1  
        @response.code.should eq("200")        
      end
      
      pending "it should not work when user has already voted"
    end

    describe :change_approval do 
      it "it should invert approval" do
        previous_approval = @record.is_approved?   
        post :change_approval, {:record_id => @record.id, :record_type => @record.class.name, :controller => "plugin"}
        assigns[:record].is_approved?.should == !previous_approval
        flash[:success].should_not be_nil
      end
      
      pending "it should not work when creator does not own record"
    end
  end
end
