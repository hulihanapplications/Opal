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
      @record = Factory(:item, :user => @controller.set_user)
      @description = Factory(:plugin_description, :record => @record)   
    end 
        
    describe "new" do
      it "should return 200" do         
        get :new, {:record_type => @record.class.name, :record_id => @record.id}
        @response.code.should eq("200")
      end
    end

    describe "edit" do
      it "should return 200" do
        get :edit, {:record_id => @description.id, :record_type => @description.class.name}
        @response.code.should eq("200")
      end
    end  
    
    describe "create" do 
      it "should work normally" do
        expect{
          post(:create, {:record_id =>  @record.id, :record_type => @record.class.name, :description => Factory.attributes_for(:plugin_description)})
        }.to change(PluginDescription, :count).by(+1)
        flash[:success].should_not be_nil
      end        
    end

    describe :update do 
      it "should work normally" do
      	new_content = random_content
        post(:update, {:record_id => @description.id, :record_type => @description.class.name, :description => {:content => new_content}})
        PluginDescription.find(@description.id).content == new_content
        flash[:success].should_not be_nil     
      end      	
    end
 
   	describe "destroy" do 
   	  it "should reduce count and return success" do
        expect{
          post(:delete, {:record_id => @description.id, :record_type => @description.class.name})
          flash[:success].should_not be_nil
        }.to change(PluginDescription, :count).by(-1) 
   	  end	
   	end   
  end
end
