require 'spec_helper'

describe PluginCommentsController do  
  render_views
  
  context "as admin" do
    before(:each) do
      login_admin
    end 
  end
  
  context "as user" do
    before(:each) do
      login_user 
      @item = Factory(:item, :user => current_user)
      @comment = Factory(:plugin_comment, :record => @item, :user => @controller.set_user)   
    end 
        
    describe "new" do
      it "should return 200" do 
        get :new, {:record_type => @item.class.name, :record_id => @item.id}
        @response.code.should eq("200")
      end

      it "should return 200 with json format" do 
        get :new, {:record_type => @item.class.name, :record_id => @item.id}, :format => :json
        @response.code.should eq("200")
      end      
    end

    describe "edit" do
      it "should return 200" do
        get :edit, {:record_type =>  @comment.class.name, :record_id => @comment.id}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, { :record_type => @item.class.name, :record_id => @item.id, :plugin_comment => Factory.attributes_for(:plugin_comment)})
        }.to change(PluginComment, :count).by(+1)
        flash[:success].should_not be_nil     
      end   
      
      it "should work when trying to add to another user's item" do 
         expect{
          item = Factory(:item)
          post(:create, {:record_type => item.class.name, :record_id => item.id, :plugin_comment => Factory.attributes_for(:plugin_comment)})
        }.to change(PluginComment, :count).by(+1)
        flash[:success].should_not be_nil       
      end  
      

      context "when comment is a reply to another comment" do
        it "parent_id should get saved if provided" do         
          item = Factory(:item)
          parent = Factory(:plugin_comment, :record => item)
          post(:create, { :record_type => item.class.name, :record_id => item.id, :plugin_comment => Factory.attributes_for(:plugin_comment, :parent_id => parent.id)})
          assigns[:plugin_comment].parent_id.should == parent.id
          flash[:success].should_not be_nil       
        end     
        
        it "should send an email to the parent owner when they are a regular user" do
          parent = Factory(:plugin_comment)          
          post(:create, { :record_type => @item.class.name, :record_id => @item.id, :plugin_comment => Factory.attributes_for(:plugin_comment, :parent_id => parent.id)})
          ActionMailer::Base.deliveries.empty?.should == false 
        end 

        it "should not send an email to the parent owner if they don't want notifications" do
          user = Factory(:user)
          user.user_info.update_attribute(:notify_of_item_changes, false) # turn off user's notification setting
          parent = Factory(:plugin_comment, :user => user)        
          ActionMailer::Base.deliveries.clear # clear out unrelated emails  
          post(:create, { :record_type => @item.class.name, :record_id => @item.id, :plugin_comment => Factory.attributes_for(:plugin_comment, :parent_id => parent.id)})
          ActionMailer::Base.deliveries.empty?.should == true           
        end 
        
        it "should send an email to the parent owner when they are a visitor" do
          parent = Factory(:plugin_comment_anonymous)          
          post(:create, { :record_type => @item.class.name, :record_id => @item.id, :plugin_comment => Factory.attributes_for(:plugin_comment, :parent_id => parent.id)})
          ActionMailer::Base.deliveries.empty?.should == false           
        end        
      end   
    end
    
    describe :update do 
      it "should work normally" do
        new_content = random_content
        post(:update, { :record_type => @comment.class.name, :record_id => @comment.id, :comment => {:comment => new_content}})
        PluginComment.find(@comment.id).comment == new_content
        flash[:success].should_not be_nil     
      end       
    end
    
    describe :destroy do
      it "decrements count" do
        expect{
          post(:delete, {:record_type => @comment.class.name, :record_id => @comment.id})
        }.to change(PluginComment, :count).by(-1)
        flash[:success].should_not be_nil
      end       
    end
    
    pending :vote
    pending :change_approval
  end
  
  context "as anonymous" do 
    before(:each) do
      login_anonymous
      stub_captcha
    end     
       
    describe :create do
      it "should work when created by an anonymous user" do
        record = Factory(:item)
        expect{
          post(:create, {:record_type => record.class.name, :record_id => record.id, :plugin_comment => Factory.attributes_for(:plugin_comment_anonymous)})
          flash[:success].should_not be_nil     
        }.to change(PluginComment, :count).by(+1)
      end      
    end 
  end
end
