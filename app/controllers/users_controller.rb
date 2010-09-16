class UsersController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 

   def index
        #@users = User.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => "username ASC"
        @users = User.paginate :page => params[:page], :per_page => 100, :order => "username ASC"
        #@users = User.find(:all, :order => "username ASC")
        @setting[:meta_title] = "Users - Admin - "+ @setting[:meta_title]
        
        @latest_logins = User.find(:all, :limit => 5, :order => "last_login DESC")
   end
   
    def create
      @user = User.new(params[:user])
      if params[:is_admin] == "1"
        @user.is_admin = "1" # Make user an admin 
      end
      
      @user.is_verified = "1"
      
      if @user.save # save successful
        flash[:notice] = "<div class=\"flash_success\">User was successfully created.</div>"
        
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => "Created #{@user.username}(#{@user.id}).")
      else
        flash[:notice] = "<div class=\"flash_failure\">User could not be created!  Here's why:<br>#{print_errors(@user)}</div>"
      end
      redirect_to :action => 'index'
    end
  
   
   def update
      @user = User.find(params[:id])
      if params[:is_admin] == "1"
        @user.update_attribute("is_admin", "1") # Make user an admin 
      end
      
      if @user.update_attributes(params[:user])
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Updated #{@user.username}(#{@user.id}).")
        flash[:notice] = "<div class=\"flash_success\">User was successfully updated.</div>"
      else
        flash[:notice] = "<div class=\"flash_failure\">User could not be updated!  Here's why:<br>#{print_errors(@user)}</div>"
      end
      redirect_to :action => "edit", :id => @user.id
   end
  
   def delete 
     if params[:id].to_i == @logged_in_user.id.to_i
       flash[:notice] = "<div class=\"flash_failure\">Sorry, You can't delete the user you're logged in as.</div>"
     else
       @user = User.find(params[:id])
       Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => "Deleted #{@user.username}(#{@user.id}).")
       flash[:notice] = "<div class=\"flash_success\">User deleted!</div>"
       @user.destroy
     end
     redirect_to :action => 'index'
   end
   
   def change_password
     @user = User.find(params[:id])
     if params[:user][:password].blank? # password is empty
       flash[:notice] = "<div class=\"flash_failure\">You didn't fill in a password box. Try Again!</div>"
     else #password is filled
      if params[:user][:password] != params[:user][:password_confirmation] # password doesn't match!
       flash[:notice] = "<div class=\"flash_failure\">Your passwords do not match!</div>"
      else#passwords match
       @user.password = params[:user][:password] 
       if @user.save
         Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Changed #{@user.username}'s password.")
         flash[:notice] = "<div class=\"flash_success\">Password Changed Successfully!</div>"
       else
         flash[:notice] = "<div class=\"flash_failure\">Password Change Failed!</div>"
       end
      end
     end
     redirect_to :action => "edit", :id => @user.id
   end

  def edit
    @user = User.find(params[:id])
  end

  def new
  end

  def toggle_user_disabled
    @user = User.find(params[:id])
    if @user.is_enabled?
      flag = "1"   # make disabled
      log_msg = "Disabled #{@user.username}'s account."
    else # if user was disabled
      flag = "0"  # make enabled
      log_msg = "Enabled #{@user.username}'s account."
    end  
    if @user.update_attribute(:is_disabled, flag)
      flash[:notice] = "<div class=\"flash_success\">User Updated!</div>"
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => log_msg)
    end
    redirect_to :action => "edit", :id => @user.id    
  end

  def toggle_user_verified
    @user = User.find(params[:id])
    if @user.is_verified?
      flag = "0"   # make unverified
    else # if user was unverified
      flag = "1"  # make verified
    end  
    if @user.update_attribute(:is_verified, flag)
      Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => "Verified #{@user.username}.")
      flash[:notice] = "<div class=\"flash_success\">User Updated!</div>"
    end
    redirect_to :action => "edit", :id => @user.id    
  end  

  def send_verification_email
    @user = User.find(params[:id])
    verification = UserVerification.find_by_user_id(@user.id)
    url = url_for(:action => "verify", :controller => "user", :id => verification.id, :code =>  verification.code, :only_path => false)
    verification = UserVerification.create(:user_id => @user.id, :code => UserVerification.generate_code) if !verification # if none found, create new verification email 
    Emailer.deliver_verification_email(@user.email, verification, url)
    Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Verification Email sent to #{@user.username}.")                                                  
    flash[:notice] = "<div class=\"flash_success\">Verification email sent!</div>"
    redirect_to :action => "edit", :controller => "users", :id => @user.id
  end

 def update_user_info
  if request.post?
   @user = User.find(params[:id])
   #@user_info = @user.user_info
     if @user.user_info.update_attributes(params[:user_info])
     Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Updated #{@user.username}'s User Info.")                                              
     flash[:notice] = "<div class=\"flash_success\">Info Changed Successfully!</div>"
     end
    redirect_to :action => "edit", :controller => "users", :id => @user.id
  end
 end

 def change_group
   @user = User.find(params[:id])
   @group = Group.find(params[:group_id])
   @user.group_id = @group.id
     if @user.save
     Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Changed #{@user.username}'s group to #{@group.name}.")                                              
     flash[:notice] = "<div class=\"flash_success\">Group Changed Successfully!</div>"
     end
    redirect_to :action => "edit", :controller => "users", :id => @user.id
 end

end
