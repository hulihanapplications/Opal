require 'spec_helper'

describe PluginDescriptionsController do  
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
      @description = Factory(:plugin_description, :item => @item)   
    end 
        
    describe "new" do
      it "should return 200" do         
        get :new, {:id =>  @item.id}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        get :edit, {:id =>  @description.item.id, :description_id => @description.id}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, {:id => @item.id, :description => Factory.attributes_for(:plugin_description)})
        }.to change(PluginDescription, :count).by(+1)
        flash[:success].should_not be_nil
      end        
    end

    describe :update do 
      it "should work normally" do
      	new_content = random_content
        post(:update, { :id => @description.item.id, :description_id => @description.id, :description => {:content => new_content}})
        PluginDescription.find(@description.id).content == new_content
        flash[:success].should_not be_nil     
      end      	
    end
 
   	describe "destroy" do 
   	  it "should reduce count and return success" do
        expect{
          post(:delete, {:id => @item.id, :description_id => @description.id})
        }.to change(PluginDescription, :count).by(-1) 
        flash[:success].should_not be_nil
   	  end	
   	end   
  end
end
