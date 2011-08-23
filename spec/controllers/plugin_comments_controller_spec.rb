require 'spec_helper'

describe PluginCommentsController do  
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
      @comment = Factory(:plugin_comment, :item => @item)   
    end 
        
    describe "new" do
      it "should return 200" do 
        get :new, {:id => @item.id}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        get :edit, {:id =>  @comment.item.id, :comment_id => @comment.id}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, { :id => @item.id, :plugin_comment => Factory.attributes_for(:plugin_comment)})
        }.to change(PluginComment, :count).by(+1)
        flash[:success].should_not be_nil     
      end   
      
      it "should work when trying to add to another user's item" do 
         expect{
          item = Factory(:item)
          post(:create, { :id => item.id, :plugin_comment => Factory.attributes_for(:plugin_comment)})
        }.to change(PluginComment, :count).by(+1)
        flash[:success].should_not be_nil       
      end  
      
      it "parent_id should get saved if used" do         
        item = Factory(:item)
        parent = Factory(:plugin_comment, :item => item)
        post(:create, { :id => item.id, :plugin_comment => Factory.attributes_for(:plugin_comment, :parent_id => parent.id)})
        assigns[:plugin_comment].parent_id.should == parent.id
        flash[:success].should_not be_nil       
      end        
    end
    
    describe :update do 
      it "should work normally" do
        new_content = random_content
        post(:update, { :id => @comment.item.id, :comment_id => @comment.id, :comment => {:comment => new_content}})
        PluginComment.find(@comment.id).comment == new_content
        flash[:success].should_not be_nil     
      end       
    end
    
    describe :destroy do
      it "decrements count" do
        expect{
          post(:delete, {:id => @comment.item.id, :comment_id => @comment.id})
        }.to change(PluginComment, :count).by(-1)
        flash[:success].should_not be_nil
      end       
    end
    
    pending :vote
    pending :change_approval
  end
  
  context "as anonymous" do    
    describe :create do
      it "should work when created by an anonymous user" do
        expect{
          post(:create, { :id => Factory(:item).id, :plugin_comment => Factory.attributes_for(:plugin_comment_anonymous)})
        }.to change(PluginComment, :count).by(+1)
        flash[:success].should_not be_nil     
      end      
    end 
  end
end
