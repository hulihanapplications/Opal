require 'spec_helper'

describe SettingsController do  
  render_views
  
  context "as admin" do
    before(:each) do
      login_admin
    end 

    describe :index do
      it "GET index returns 200" do
        get :index
        response.code.should eq("200")
      end          
    end

    describe :new_change_logo do
      it "returns 200" do
        get :new_change_logo
        response.code.should eq("200")
      end    
    end
    
    describe :change_logo do 

      it "uploads a remote logo" do
				image_path = Rails.root.to_s + "/public/themes/fracture/images/logo.png" # location of main logo
				if File.file?(image_path) 
					image_saved = Rails.root.to_s + "/public/themes/fracture/images/logo-saved.png" # temp save location for the original logo
					FileUtils.mv(image_path, image_saved)
				end
				post(:change_logo, { :source => :remote, :url => "http://hulihanapplications.com/images/quick_links/opal_tiny.png" } )
				flash[:success].should_not == nil
				File.file?(image_path).should == true
				response.should redirect_to(:action => :index, :controller => :settings)
				FileUtils.rm(image_path)
				FileUtils.mv(image_saved, image_path) unless image_saved.nil?
			end

      it "uploads a local logo" do
				image_path = Rails.root.to_s + "/public/themes/fracture/images/logo.png" # location of main logo
				@testimage = fixture_file_upload(Rails.root.to_s + '/spec/fixtures/images/example.png')
				# start of dirty-hack-that-we-should-get-rid-off-soon
				# this hack was suggested on http://stackoverflow.com/questions/7793510/mocking-file-uploads-in-rails-3-1-controller-tests
				# and is mostly for rails 3 compat. Smells a bit bad but well, it works ...
				class << @testimage
					attr_reader :tempfile
				end
				# end of dirty-hack-that-we-should-get-rid-off-soon
				if File.file?(image_path) 
					image_saved = Rails.root.to_s + "/public/themes/fracture/images/logo-saved.png" # temp save location for the original logo
					FileUtils.mv(image_path, image_saved)
				end
				post(:change_logo, { :source => :local, :file => @testimage })
				flash[:success].should_not == nil
				File.file?(image_path).should == true
				response.should redirect_to(:action => :index, :controller => :settings)
				FileUtils.rm(image_path)
				FileUtils.mv(image_saved, image_path) unless image_saved.nil?
			end
			pending "uploading a non-image logo"
    end

    describe :delete_logo do 
			it "really erases the logo" do
				image_path = Rails.root.to_s + "/public/themes/fracture/images/logo.png" # location of main logo
				if File.file?(image_path)
					image_saved = Rails.root.to_s + "/public/themes/fracture/images/logo-saved.png" # temp save location for the original logo
					FileUtils.mv(image_path, image_saved)
				end
				FileUtils.touch(image_path)
				get(:delete_logo)
				flash[:success].should_not == nil
				File.file?(image_path).should == false
				response.should redirect_to(:action => :index, :controller => :settings, :anchor => :Logo)
				FileUtils.mv(image_saved, image_path) unless image_saved.nil?
			end
    end  
    
    describe :themes do
      it "returns 200" do
        get :themes
        response.code.should eq("200")
      end    
    end
    
    describe :new_theme_install do
      it "returns 200" do
        get :new_theme_install
        response.code.should eq("200")
      end    
    end  
    
    describe :install_theme do
      pending :it_works
    end        

    describe :delete_theme do
      pending :it_works
    end           
  end
end
