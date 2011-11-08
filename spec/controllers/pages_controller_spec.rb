require 'spec_helper'

describe PagesController do  
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
        get :edit, {:id => Factory(:page).id}
        response.code.should eq("200")
      end      
    end
    
    describe "create" do
      it "adds a page" do
        expect{
          post(:create, {:page => Factory.attributes_for(:page)})
        }.to change(Page, :count).by(+1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "index", :type => assigns[:page].page_type.capitalize)
      end      
      
      it "renders new when name is missing" do
        expect{
          post(:create, {:page => Factory.attributes_for(:page, :title => nil)})
        }.to change(Page, :count).by(0)
        flash[:failure].should_not be_nil
        @response.should render_template("new", :type => assigns[:page].page_type.capitalize)
      end
    end
    
    describe "destroy" do
      it "destroys a page" do
        page = Factory(:page)
        expect{
          post(:delete, {:id => page.id})
        }.to change(Page, :count).by(-1)
        flash[:success].should_not be_nil
        @response.should redirect_to(:action => "index", :type => assigns[:page].page_type.capitalize)
      end      
    end   
    
    describe "update" do
      it "saves changes" do
        page = Factory(:page)       
        post(:update, {:id => page.id, :page => {:name => "New Name"}})
        flash[:success].should_not be_nil
        Page.find(page.id).name.should == "New Name" 
        @response.should redirect_to(:action => "edit", :id => assigns[:page].id, :type => assigns[:page].page_type.capitalize)
      end      
    end
    
        
    pending "tinymce_images"
    pending "upload_image"
    pending "delete_image"
    pending "update_order"
  end
  
  context "as visitor" do
    describe "view" do
      it "should return 200" do 
        get :view, {:id =>  Factory(:page)}
        @response.code.should eq("200")
      end
      
      it "should redirect when redirect is true and redirect_url is not blank" do
        @page = Factory(:page_with_redirect)
        get :view, {:id => @page.id}
        @response.should redirect_to(@page.redirect_url)
      end 
    end
    
    pending "send_contact_us"
  end
end
