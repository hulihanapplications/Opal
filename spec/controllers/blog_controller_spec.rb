require 'spec_helper'

describe BlogController do
  render_views
  
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
      get :post, :id => Page.blog.published.first.id
      @response.code.should eq("200")
    end 
  end
  
  describe "rss" do
    it "should work" do
      get :rss, {:format => :xml}
      @response.code.should eq("200")
    end 
  end  
end
