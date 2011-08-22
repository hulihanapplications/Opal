require 'spec_helper'

describe PluginImagesController do  
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
    end 
        
    describe "new" do
      it "should return 200" do         
        get :new, {:id =>  @item.id}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        @image = Factory(:plugin_image, :item => @item)
        get :edit, {:id =>  @image.item.id, :image_id => @image.id}
        @response.code.should eq("200")
        @image.destroy # clean up
      end
    end  
    
    describe "create" do 
      it "should work with local file" do
        expect{
          post(:create, {:id => @item.id, :plugin_image => Factory.attributes_for(:plugin_image)})
        }.to change(PluginImage, :count).by(+1)
        flash[:success].should_not be_nil
        assigns[:image].destroy # clean up
      end 

      it "should fail with unresponsive url" do
        item = Factory(:item)
        expect{
          post(:create, {:id => @item.id, :plugin_image => Factory.attributes_for(:plugin_image_remote, :remote_file => "http://localhost")})
        }.to change(PluginImage, :count).by(0)
        flash[:failure].should_not be_nil
      end     
    end
   	
   	describe "destroy" do 
   	  it "should reduce count and return success" do
   		@image = Factory(:plugin_image, :item => @item)
        expect{
          post(:delete, {:id => @item.id, :image_id => @image.id})
        }.to change(PluginImage, :count).by(-1) 
        flash[:success].should_not be_nil
   	  end	
   	end
  end
end
