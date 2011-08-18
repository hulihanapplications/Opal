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
      @image = Factory(:plugin_image, :item => @item)         
    end 
        
    describe "new" do
      it "should return 200" do 
      	PluginImage.stub!(:validate_source).and_return(true)
        get :new, {:id =>  Factory(:plugin_image)}
        @response.code.should eq("200")
      end
    end
=begin  
    describe "edit" do
      it "should return 200" do
        image = Factory(:plugin_image_remote) 
        get :edit, {:id =>  image.item.id, :image_id => image.id}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should fail with unresponive url" do
        item = Factory(:item)
        expect{
          post(:create, {:id => item.id, :plugin_image => {:remote_file => "http://localhost"}})
        }.to change(PluginImage, :count).by(+1)
        puts assigns[:image].errors.inspect
        flash[:success].should_not be_nil
      end     
    end
=end    
  end
end
