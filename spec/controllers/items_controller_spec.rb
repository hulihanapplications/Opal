require 'spec_helper'

describe ItemsController do  
  render_views
  
  describe "as admin" do
    before(:each) do
      login_admin
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
      
      it "renders new when name is missing" do
        expect{
          post(:create, {:item => Factory.attributes_for(:item, :name => nil)})
        }.to change(Item, :count).by(0)
        flash[:failure].should_not be_nil
        @response.should render_template("new")
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
    
    describe "all_items" do
      it "should return 200" do 
        get :all_items
        @response.code.should eq("200")
      end
    end
        
    describe "change_item_name" do
      it "should return 200" do 
        get :change_item_name
        @response.code.should eq("200")
      end 
    end
     
    pending "do_change_item_name"
    
    describe "set_preview" do
      it "should work with the right params" do
        item = Factory(:item)
        post :set_preview, {:id => item, :preview_id => Factory(:plugin_image, :record => item).id, :preview_type => PluginImage.name}
        flash[:success].should_not be_nil
        item.preview_type.should == PluginImage.name
        @response.code.should eq("302")
      end 
    end
  end
  
  context "as user" do 
    before(:each) do
      login_user 
    end 
        
    describe "create" do
      it "fails when user has created maximum amount of items" do
        Setting.set(:max_items_per_user, 1)
        previously_created_item = Factory(:item, :user => current_user)
        expect{
          post(:create, {:item => Factory.attributes_for(:item)})
        }.to change(Item, :count).by(0)
        flash[:failure].should_not be_nil
      end      
    end   
  end
  
  context "as visitor" do 
    describe "index" do
      it "GET index returns 200" do
        get :index
        response.code.should eq("200")
      end      
      
      it "should work with detailed item list" do
        Setting.find_by_name("list_type").update_attribute(:value, "detailed")
        get :index
        response.code.should eq("200")
      end      
      
      it "should work with simple item list" do
        Setting.find_by_name("list_type").update_attribute(:value, "simple")
        get :index
        response.code.should eq("200")
      end     
      
      it "should work with photo item list" do
        Setting.find_by_name("list_type").update_attribute(:value, "photo")
        get :index
        response.code.should eq("200")
      end        
      
      it "should work with small item list" do
        Setting.find_by_name("list_type").update_attribute(:value, "small")
        get :index
        response.code.should eq("200")
      end        
    end
    
    describe "category" do
      it "should return 200" do 
        get :category, {:id =>  Factory(:category)}
        @response.code.should eq("200")
      end
    end

    describe "view" do
      it "should return 200" do 
        get :view, {:id =>  Factory(:item_with_plugins)}
        @response.code.should eq("200")
      end
    end
        
    describe "rss" do
      it "should return 200" do 
        get :rss, {:id =>  Factory(:item_with_plugins), :format => :xml}
        @response.code.should eq("200")
      end
    end   

    describe "tag" do
      it "should return 200" do 
        item = Factory(:item_with_plugins)
        get :tag, {:tag =>  PluginTag.first.name}
        @response.code.should eq("200")
      end
    end       

    describe "advanced_search" do
      it "should return 200" do 
        get :advanced_search
        @response.code.should eq("200")
      end
    end     
    
    describe "do_advanced_search" do
      it "should work without any input" do
        post :do_advanced_search
        @response.code.should eq("200")
      end
      
      it "should work when passed a keyword" do
        post :do_advanced_search, {:search => {:keywords => "test"}}
        @response.code.should eq("200")
      end      
    end 
    
    pending "set_list_type"
    pending "set_item_page_type"   
  end
end
