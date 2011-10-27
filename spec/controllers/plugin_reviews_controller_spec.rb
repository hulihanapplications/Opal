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
      @record = Factory(:item, :user => @controller.set_user)
      @review = Factory(:plugin_review, :record => @record)   
    end 
        
    describe "new" do
      it "should return 200" do 
        get :new, {:record_type => @record.class.name, :record_id => @record.id}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        get :edit, {:record_type => @review.class.name, :record_id => @review.id}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, { :record_type => @record.class.name, :record_id => @record.id, :review => Factory.attributes_for(:plugin_review)})
        }.to change(PluginReview, :count).by(+1)
        flash[:success].should_not be_nil     
      end   
      
      it "should work when trying to add to another user's item" do 
         expect{
          record = Factory(:item)
          post(:create, { :record_type => record.class.name, :record_id => record.id, :review => Factory.attributes_for(:plugin_review)})
        }.to change(PluginReview, :count).by(+1)
        flash[:success].should_not be_nil      	
      end  
    end
    
    describe :update do 
      it "should work normally" do
      	new_content = random_content
        post(:update, { :record_type => @review.class.name, :record_id => @review.id, :review => {:review => new_content, :review_score => @review.review_score}})
        PluginReview.find(@review.id).review == new_content
        flash[:success].should_not be_nil     
      end      	
    end
    
    describe :destroy do
      it "decrements count" do
        expect{
          post(:delete, {:record_type => @review.class.name, :record_id => @review.id})
        }.to change(PluginReview, :count).by(-1)
        flash[:success].should_not be_nil
      end     	
    end
    
    pending :vote
    pending :change_approval
  end

end
