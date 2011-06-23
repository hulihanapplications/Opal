require 'spec_helper'

describe CategoriesController do  
  render_views
  
  describe "as admin" do
    before(:each) do
      login_admin
    end 

    it "GET index returns 200" do
      get :index
      response.code.should eq("200")
    end  
    
    describe "new" do
      it "returns 200" do
        get :new
        response.code.should eq("200")
      end      
    end

    describe "create" do
      it "adds a category" do
        expect{
          post(:create, {:category => Factory.attributes_for(:category)})
        }.to change(Category, :count).by(+1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "index")
      end      
    end
    
    describe "destroy" do
      it "destroys a category" do
        category = Factory(:category)
        expect{
          post(:delete, {:id => category.id})
        }.to change(Category, :count).by(-1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "index")
      end      
    end    
  end
end
