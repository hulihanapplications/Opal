require 'spec_helper'

describe UsersController do  
  render_views
  
  describe "as admin" do
    before(:each) do
      login_admin
    end 
    
    describe "index" do
      it "returns 200" do
        get :index
        response.code.should eq("200")
      end      
    end

    describe "new" do
      it "returns 200" do
        get :new
        response.code.should eq("200")
      end      
    end
    
    describe "create" do
      it "increments count" do
        expect{
          post(:create, {:user => Factory.attributes_for(:user)})
        }.to change(User, :count).by(+1)
        flash[:success].should_not be_nil
        @response.should redirect_to(users_path)
      end      
    end
    
    describe "destroy" do
      it "decrements count" do
        user = Factory(:user)
        expect{
          post(:destroy, {:id => user.id})
        }.to change(User, :count).by(-1)
        flash[:success].should_not be_nil
        @response.should redirect_to(users_path)
      end      
    end   

    describe "edit" do
      it "returns 200" do
        user = Factory(:user)       
        get(:edit, {:id => user.id})
        response.code.should eq("200")
      end      
    end
    
    describe "update" do
      it "works when changing username" do
        user = Factory(:user)       
        new_username = random_content
        post(:update, {:id => user.id, :user => {:username => new_username}})
        flash[:success].should_not be_nil
        User.find(user.id).username.should == new_username
      end      
    end
    
		describe "toggle_user_disabled" do
			it "enables the disabled user" do
				user = Factory(:user)
				user.update_attribute(:is_disabled, "1")
				get(:toggle_user_disabled, {:id => user.id})
				flash[:success].should_not be_nil
				User.find(user.id).is_disabled.should == "0"
			end
			it "disables the enabled user" do
				user = Factory(:user)
				user.update_attribute(:is_disabled, "0")
				get(:toggle_user_disabled, {:id => user.id})
				flash[:success].should_not be_nil
				User.find(user.id).is_disabled.should == "1"
			end
		end

		describe "toggle_user_verified" do
			it "unverifies the verified user" do
				user = Factory(:user)
				user.update_attribute(:is_verified, "1")
				get(:toggle_user_verified, {:id => user.id})
				flash[:success].should_not be_nil
				User.find(user.id).is_verified.should == "0"
			end
			it "verifies the unverified user" do
				user = Factory(:user)
				user.update_attribute(:is_verified, "0")
				get(:toggle_user_verified, {:id => user.id})
				flash[:success].should_not be_nil
				User.find(user.id).is_verified.should == "1"
			end
		end

		pending "send_verification_email"
#     describe "send_verification_email" do
# 			it "sends an email to verify an account" do
# 				user = Factory(:user)
# 				get(:send_verification_email, {:id => user.id})
# 				flash[:success].should_not be_nil
# 				ActionMailer::Base.deliveries.last.to.should == [user.email]
# 			end
# 		end

  end
  
  context "as user" do
    before(:each) do
      login_user
      #@user = Factory(:item, :user => @controller.set_user)
    end
    
    describe "change_password" do
			before(:each) do
				@user = @controller.set_user
				@pass = "totototo"
			end
			it "fails when password is badly confirmed" do
				post(:change_password, {:id => @user.id, :user => {:password => @pass, :password_confirmation => "tutututu" }})
				flash[:failure].should_not be_nil
			end
			it "works fine" do
				post(:change_password, {:id => @user.id, :user => {:password => @pass, :password_confirmation => @pass }})
				flash[:success].should_not be_nil
				response.should redirect_to(edit_user_path(@user))
				User.find(@user.id).password?(@pass).should == true
			end
		end
    
    describe "change_avatar" do
      it "works properly" do
        file = File.new(Rails.root + 'spec/fixtures/images/example.png')
        post(:change_avatar, {:id => @controller.set_user.id, :avatar => ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file.path))})
        flash[:success].should_not be_nil
        response.should redirect_to edit_user_path(@controller.set_user)         
      end
    end 
    
    describe "verification_required" do
			it "displays a page" do
				get :verification_required
				response.should be_successful
			end
		end

  end 
  
  context "as visitor" do
    describe "show"  do
			it "displays a page" do
				get :show, :id => Factory(:user).id
				response.should be_successful
			end
		end
  end 
end
