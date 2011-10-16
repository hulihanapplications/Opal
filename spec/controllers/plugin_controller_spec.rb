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
        expect{        
          post :vote, {:record_id => @record.id, :record_type => @record.class.controller_name, :controller => "plugin", :direction => "up"}
        }.to change(PluginImage, :count).by(+1)
        @response.code.should eq("200")        
      end
    end

    describe :change_approval do 
      it "it should work" do
        expect{        
          post :change_approval, {:record_id => @record.id, :record_type => @record.class.controller_name, :controller => "plugin", :direction => "up"}
        }.to change(@record, :is_approved?).to("0")
        @response.code.should eq("200")        
      end
    end
  end
end
