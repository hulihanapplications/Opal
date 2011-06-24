require 'spec_helper'

describe ItemsController do  
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

    describe "edit" do
      it "returns 200" do
        get :edit, {:id => Factory(:item).id}
        response.code.should eq("200")
      end      
    end
    
    describe "create" do
      it "adds a item" do
        expect{
          post(:create, {:item => Factory.attributes_for(:item)})
        }.to change(Item, :count).by(+1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "view", :id => assigns[:item])
      end      
    end
    
    describe "destroy" do
      it "destroys a item" do
        item = Factory(:item)
        expect{
          post(:delete, {:id => item.id})
        }.to change(Item, :count).by(-1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "my")
      end      
    end   
    
    describe "update" do
      it "saves changes" do
        item = Factory(:item)       
        post(:update, {:id => item.id, :item => {:name => "New Name"}})
        flash[:success].should_not be_nil
        Item.find(item.id).name.should == "New Name" 
      end      
    end
    
    pending "all_items"
    pending "change_item_name"
    pending "do_change_item_name"
  end
  
  context "as visitor" do 
    describe "category" do
      it "should return 200" do 
        get :category, {:id =>  Factory(:category)}
        @response.code.should eq("200")
      end
    end
    
    pending "rss"
    pending "tag"
    pending "view"
    pending "search"
    pending "new_advanced_search"
    pending "advanced_search"
    pending "set_list_type"
    pending "set_item_page_type"   
  end
end
