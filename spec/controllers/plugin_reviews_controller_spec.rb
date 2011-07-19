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
    end 
        
    describe "new" do
      it "should return 200" do 
        get :new, {:id =>  Factory(:plugin_review)}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        review = Factory(:plugin_review) 
        get :edit, {:id =>  review.item.id, :review_id => review.id}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should increment count" do
        item = Factory(:item)
        expect{
          post(:create, {:id => item.id, :plugin_review => Factory.attributes_for(:plugin_review)})
        }.to change(PluginReview, :count).by(+1)
        puts assigns[:review].errors.inspect
        flash[:success].should_not be_nil
      end     
    end
    
    pending :update
    pending :delete
    pending :vote
    pending :change_approval
  end
  
  context "as visitor" do 
    describe "show" do
      it "should return 200" do 
        get :show, {:id =>  Factory(:plugin_review)}
        @response.code.should eq("200")
      end
    end    
  end
end
