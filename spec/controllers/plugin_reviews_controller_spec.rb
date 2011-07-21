require 'spec_helper'

describe PluginReviewsController do  
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
      @review = Factory(:plugin_review, :item => @item)   
    end 
        
    describe "new" do
      it "should return 200" do 
        get :new, {:id => @item.id}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        get :edit, {:id =>  @review.item.id, :review_id => @review.id}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, { :id => @item.id, :review => Factory.attributes_for(:plugin_review)})
        }.to change(PluginReview, :count).by(+1)
        flash[:success].should_not be_nil     
      end   
      
      it "should work when trying to add to another user's item" do 
         expect{
          item = Factory(:item)
          post(:create, { :id => item.id, :review => Factory.attributes_for(:plugin_review)})
        }.to change(PluginReview, :count).by(+1)
        flash[:success].should_not be_nil      	
      end  
    end
    
    describe :update do 
      it "should work normally" do
      	new_content = random_content
        post(:update, { :id => @review.item.id, :review_id => @review.id, :review => {:review => new_content, :review_score => @review.review_score}})
        PluginReview.find(@review.id).review == new_content
        flash[:success].should_not be_nil     
      end      	
    end
    
    describe :destroy do
      it "decrements count" do
        expect{
          post(:delete, {:id => @review.item.id, :review_id => @review.id})
        }.to change(PluginReview, :count).by(-1)
        flash[:success].should_not be_nil
      end     	
    end
    
    pending :vote
    pending :change_approval
  end

end
