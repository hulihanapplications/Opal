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
    
		describe "handling the site logo," do
			before(:all) do
				@image_path = Rails.root.to_s + "/public/themes/fracture/images/logo.png" # location of main logo
				if File.file?(@image_path) 
					@image_saved = Rails.root.to_s + "/public/themes/fracture/images/logo-saved.png" # temp save location for the original logo
					FileUtils.mv(@image_path, @image_saved)
				end
				
			end

			after(:all) do
				FileUtils.rm(@image_path) if File.file?(@image_path)
				FileUtils.mv(@image_saved, @image_path) unless @image_saved.nil?
			end
			
			describe :change_logo do 

				it "uploads a remote logo" do
					post(:change_logo, { :source => :remote, :url => "http://hulihanapplications.com/images/quick_links/opal_tiny.png" } )
					flash[:success].should_not == nil
					File.file?(@image_path).should == true
					response.should redirect_to(:action => :index, :controller => :settings)
				end

				it "uploads a local logo" do
					@testimage = fixture_file_upload(Rails.root.to_s + '/spec/fixtures/images/example.png')
					# start of dirty-hack-that-we-should-get-rid-off-soon
					# this hack was suggested on http://stackoverflow.com/questions/7793510/mocking-file-uploads-in-rails-3-1-controller-tests
					# and is mostly for rails 3 compat. Smells a bit bad but well, it works ...
					class << @testimage
						attr_reader :tempfile
					end
					# end of dirty-hack-that-we-should-get-rid-off-soon
					post(:change_logo, { :source => :local, :file => @testimage })
					flash[:success].should_not == nil
					File.file?(@image_path).should == true
					response.should redirect_to(:action => :index, :controller => :settings)
				end
				pending "uploading a non-image logo"
			end

			describe :delete_logo do 
				it "really erases the logo" do
					FileUtils.touch(@image_path)
					get(:delete_logo)
					flash[:success].should_not == nil
					File.file?(@image_path).should == false
					response.should redirect_to(:action => :index, :controller => :settings, :anchor => :Logo)
				end
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
			before(:all) do
				@theme_dir = Rails.root.to_s + "/public/themes/test-theme"
			end

			it "installs new theme from an url" do
				# change this url with official one from official website
				post(:install_theme, { :source => :remote, :url => "http://mose.com/test-theme.zip" } )
				flash[:success].should_not == nil
				File.directory?(@theme_dir).should == true
				File.file?(@theme_dir + "/theme.yml").should == true
				response.should redirect_to(:action => :themes, :controller => :settings)
				FileUtils.remove_dir(@theme_dir) if File.directory?(@theme_dir)
			end
			it "installs new theme from a local file" do
				@ziptheme = fixture_file_upload(Rails.root.to_s + '/spec/fixtures/test-theme.zip')
				class << @ziptheme
					attr_reader :tempfile
				end
				post(:install_theme, { :source => :local, :file => @ziptheme } )
				flash[:success].should_not == nil
				File.directory?(@theme_dir).should == true
				File.file?(File.join(@theme_dir, "theme.yml")).should == true
				response.should redirect_to(:action => :themes, :controller => :settings)
				FileUtils.remove_dir(@theme_dir) if File.directory?(@theme_dir)
			end
		end        

		describe :delete_theme do
			before(:each) do
				@theme_dir = Rails.root.to_s + "/public/themes/test-theme"
				FileUtils.cp_r(Rails.root.to_s + '/spec/fixtures/test-theme', Rails.root.to_s + '/public/themes/')
			end
			it "deletes an installed theme" do
				get(:delete_theme, { :theme_name => "test-theme" } )
				flash[:success].should_not == nil
				File.directory?(@theme_dir).should == false
				response.should redirect_to(:action => :themes, :controller => :settings)
			end
		end


  end
end
