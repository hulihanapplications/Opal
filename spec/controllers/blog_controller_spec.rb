require 'spec_helper'

describe BlogController do
  render_views
  
  before :each do 
    @post = FactoryGirl.create(:blog_post)
  end

  describe "GET index" do
    it "has a 200 status code" do
      get :index
      @response.code.should eq("200")
    end
  end
  
  describe "archive" do
    it "works without params" do
      get :archive
      @response.code.should eq("200")
    end
    
    it "works with only year" do
      get :archive, {:year => Time.now.strftime("%Y")}
      @response.code.should eq("200")
    end   

    it "works with month and year" do
      get :archive, {:year => Time.now.strftime("%Y"), :month => Time.now.strftime("%m")}
      @response.code.should eq("200")
    end    

    it "works with month and year and day" do
      get :archive, {:year => Time.now.strftime("%Y"), :month => Time.now.strftime("%m"), :day => Time.now.strftime("%d")}
      @response.code.should eq("200")
    end      
  end  
  
  describe "post" do 
    it "should work" do
      get :post, :id => @post.to_param
      @response.code.should eq("200")
    end 
  end
  
  describe "feed" do
    it "should work with ATOM" do
      get :feed, {:format => :atom}
      @response.code.should eq("200")
    end

    it "should redirect RSS" do
      get :feed, {:format => :rss}
      @response.code.should eq("302")
    end 
  end  
end
