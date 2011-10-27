require 'spec_helper'

describe PluginVideosController do  
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
    end 
        
    describe "new" do
      it "should return 200" do         
        get :new, {:record_type => @record.class.name, :record_id => @record.id}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        @video = Factory(:plugin_video, :record => @record)
        get :edit, {:record_type => @video.class.name, :record_id => @video.id}
        @response.code.should eq("200")
        @video.destroy # clean up
      end
    end  
    
    describe "create" do 
      it "should create video with embedded code" do
        expect{
          post(:create, {:record_type => @record.class.name, :record_id => @record.id, :plugin_video => Factory.attributes_for(:plugin_video)})
          flash[:success].should_not be_nil
        }.to change(PluginVideo, :count).by(+1)
        assigns[:video].destroy # clean up
      end 

      it "should create video with uplpoaded file" do
        expect{
          post(:create, {:record_type => @record.class.name, :record_id => @record.id, :plugin_video => Factory.attributes_for(:uploaded_plugin_video)})
          flash[:success].should_not be_nil
        }.to change(PluginVideo, :count).by(+1)
        assigns[:video].destroy # clean up
      end     
    end
    
    describe "destroy" do 
      it "should reduce count and return success" do
      @video = Factory(:plugin_video, :record => @record)
        expect{
          post(:delete, {:record_type => @video.class.name, :record_id => @video.id})
          flash[:success].should_not be_nil
        }.to change(PluginVideo, :count).by(-1) 
      end 
    end
  end
end
