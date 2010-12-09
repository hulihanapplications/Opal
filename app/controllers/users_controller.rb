class UsersController < ApplicationController
 before_filter :authenticate_user # must be logged in
 before_filter :find_user, :except => [:index, :create, :new]
 before_filter :authenticate_admin, :except => [:change_password, :change_avatar, :update, :edit] # make sure logged in user is an admin
#before_filter :enable_user_menu, :only => [:edit, :update]   
 before_filter :enable_admin_menu, :except => [:change_password, :change_avatar, :update, :edit]  # show admin menu 

   def find_user
    if @logged_in_user.is_admin?
      @user = User.find(params[:id])
      enable_admin_menu
    else # not admin ... select self
      @user = @logged_in_user 
      enable_user_menu
    end 
   end 
  
   def index
        @setting[:meta_title] = User.human_name.pluralize + " - " + t("section.title.admin").capitalize + " - " + @setting[:meta_title]
        #@users = User.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => "username ASC"
        @users = User.paginate :page => params[:page], :per_page => 100, :order => "username ASC"
        #@users = User.find(:all, :order => "username ASC")
        
        @latest_logins = User.find(:all, :limit => 5, :order => "last_login DESC")
   end
   
    def create
      @user = User.new(params[:user])
      @user_info = UserInfo.new(params[:user_info])
      @user_info.user_id = @user.id
      if params[:is_admin] == "1"
        @user.is_admin = "1" # Make user an admin 
      end
      
      @user.is_verified = "1"
      
      if @user.save && @user_info.save # save successful
        flash[:success] = t("notice.item_create_success", :item => User.human_name)      
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => t("log.item_create", :item => User.human_name, :name => @user.username))
        redirect_to :action => 'index'        
      else # creation failed
        render :action => "new"
      end
    end
  
   
   def update
      @user_info = @user.user_info

        if !@logged_in_user.is_admin? # handle protected attributes
          params[:user][:group_id] = @user.group_id
          params[:user][:username] = @user.username
          params[:user][:email] =  @user.email 
          params[:user][:created_at] = @user.created_at  
        end                    
                  
      if @user.update_attributes(params[:user]) && @user_info.update_attributes(params[:user_info])        
        @user.update_attribute(:is_admin, params[:user][:is_admin]) if @logged_in_user.is_admin?
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => User.human_name, :name => @user.username))
        flash[:success] = t("notice.save_success") 
        redirect_to :action => "edit", :id => @user
      else
        render :action => "edit"      
      end
   end
  
   def delete 
     if @user.id == @logged_in_user.id.to_i # trying to delete the user they're logged in as.
       flash[:failure] = t("notice.invalid_permissions")
     else
       Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => User.human_name, :name => @user.username))
       flash[:success] = t("notice.item_delete_success", :item => User.human_name) 
       @user.destroy
     end
     redirect_to :action => 'index'
   end
   
  def change_password
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => User.human_name, :name => @user.username + "(#{User.human_attribute_name(:password)}: #{params[:user][:password]})"))
      flash[:success] = t("notice.save_success") 
    else
      flash[:failure] = t("notice.save_failure") 
    end
    redirect_to :action => "edit", :id => @user
  end

  def edit
    @user_info = @user.user_info
  end

  def new
    @user = User.new
  end

  def toggle_user_disabled
    if @user.is_enabled?
      flag = "1"   # make disabled
      log_msg = t("log.item_disable", :item => User.human_name, :name => @user.username) 
    else # if user was disabled
      flag = "0"  # make enabled
      log_msg = t("log.item_enable", :item => User.human_name, :name => @user.username) 
    end  
    if @user.update_attribute(:is_disabled, flag)
      flash[:success] = t("notice.item_save_success", :item => User.human_name)
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => log_msg)
    end
    redirect_to :action => "edit", :id => @user  
  end

  def toggle_user_verified
    if @user.is_verified?
      flag = "0"   # make unverified
    else # if user was unverified
      flag = "1"  # make verified
    end  
    if @user.update_attribute(:is_verified, flag)
      Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => t("log.item_verify", :item => User.human_name, :name => @user.username))
      flash[:success] = t("notice.item_save_success", :item => User.human_name)
    end
    redirect_to :action => "edit", :id => @user    
  end  

  def send_verification_email
    verification = UserVerification.find_by_user_id(@user.id)
    verification = UserVerification.create(:user_id => @user.id, :code => UserVerification.generate_code) if !verification # if none found, create new verification email 
    if verification
      url = url_for(:action => "verify", :controller => "user", :id => verification.id, :code =>  verification.code, :only_path => false)
      Emailer.deliver_verification_email(@user.email, verification, url)
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_email_sent", :item => UserVerification.human_name, :name => @user.username))                                                  
      flash[:success] =  t("log.item_email_sent", :item => UserVerification.human_name, :name => @user.username)
    else
      flash[:failure] = t("notice.item_not_found", :item => UserVerification.human_name)
    end 
    redirect_to :action => "edit", :controller => "users", :id => @user
  end

 def change_avatar
     if !params[:file].nil? && !params[:file].empty?    #from their computer
      filename = params[:file].original_filename
      file_dir = "#{RAILS_ROOT}/public/images/avatars" 
      acceptable_file_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
      if Uploader.check_file_extension(:filename => filename, :extensions => acceptable_file_extensions)
       image = Magick::Image.from_blob(params[:file].read).first    # read in image binary
       image.crop_resized!( 100, 100 ) # Resize image
       image.write("#{file_dir}/#{@user.id.to_s}.png") # write the file
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log =>  t("log.user_account_item_save", :item => t("single.avatar")))                                                   
       flash[:success] = t("notice.save_success")     
      else
       flash[:failure] = t("notice.invalid_file_extensions", :item => Image.human_name, :acceptable_file_extensions => acceptable_file_extensions)      
      end
     else # they didn't select an image
       flash[:failure] = t("notice.item_forgot_to_select", :item => Image.human_name)      
     end

   redirect_to :action => "edit", :id => @user
 end

end
