class UsersController < ApplicationController
 before_filter :authenticate_user # must be logged in
 before_filter :find_user, :except => [:index, :create, :new]
 before_filter :authenticate_admin, :except => [:change_password, :change_avatar, :update, :edit] # make sure logged in user is an admin
 #before_filter :enable_user_menu, :only => [:edit, :update]   
 before_filter :enable_admin_menu, :except => [:change_password, :change_avatar, :update, :edit]  # show admin menu 
 before_filter :protect_against_self, :only => [:delete, :toggle_user_disabled, :toggle_user_verified] 

  def protect_against_self # prevent logged in user from performing restrictive actions against themselves 
    if defined?(@user)
       if @user.id == @logged_in_user.id # selected user is same as logged in user
          flash[:failure] = t("notice.invalid_permissions")
          redirect_to :action => "index"
       else # not the same user, proceed
          # proceed
       end 
    end 
  end 

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
        @setting[:meta_title] << User.model_name.human.pluralize 
        #@users = User.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => "username ASC"
        @users = User.paginate :page => params[:page], :per_page => 100, :order => "username ASC"
        #@users = User.find(:all, :order => "username ASC")
        
        @latest_logins = User.find(:all, :limit => 5, :order => "last_login DESC")
   end
   
    def create
      @user = User.new(params[:user])
      if @logged_in_user.is_admin? # handle protected attributes
        @user.is_admin = params[:user][:is_admin]
        @user.group_id = params[:group_id]        
      else # User is not admin
      end
      
      @user.is_verified = "1"
      
      if @user.save #&& @user_info.save # save successful
        flash[:success] = t("notice.item_create_success", :item => User.model_name.human)      
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => t("log.item_create", :item => User.model_name.human, :name => @user.username))
        redirect_to :action => 'index'        
      else # creation failed
        render :action => "new"
      end
    end
  
   
   def update
      @user_info = @user.user_info
      
      if @logged_in_user.is_admin? 
         # Manually change protected attributes
        @user.is_admin = params[:user][:is_admin] unless @logged_in_user.id == @user.id # let them change admin permission, unless they're doing it to themselves
        @user.group_id = params[:group_id]        
      else # User is not admin
        # Reset protected attributes  
        params[:user][:group_id] = @user.group_id
        params[:user][:username] = @user.username
        params[:user][:email] =  @user.email 
        params[:user][:created_at] = @user.created_at  
      end                    
 
      # Load Attributes from form using Mass Assign
      @user.attributes = params[:user]
      @user_info.attributes = params[:user_info] 
                  
      if @user.valid? && @user_info.valid?       
        if @user.save && @user_info.save 
          Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => User.model_name.human, :name => @user.username))
          flash[:success] = t("notice.save_success") 
          redirect_to :action => "edit", :id => @user
        else
          render :action => "edit"      
        end        
      else
        render :action => "edit"      
      end
   end
  
   def delete 
     Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => User.model_name.human, :name => @user.username))
     flash[:success] = t("notice.item_delete_success", :item => User.model_name.human) 
     @user.destroy
     redirect_to :action => 'index'
   end
   
  def change_password
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => User.model_name.human + "(#{User.human_attribute_name(:password)})", :name => @user.username ))
      flash[:success] = t("notice.save_success") 
      redirect_to :action => "edit", :id => @user
    else
      flash[:failure] = t("notice.save_failure") 
      render :action => "edit"
    end
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
      log_msg = t("log.item_disable", :item => User.model_name.human, :name => @user.username) 
    else # if user was disabled
      flag = "0"  # make enabled
      log_msg = t("log.item_enable", :item => User.model_name.human, :name => @user.username) 
    end  
    if @user.update_attribute(:is_disabled, flag)
      flash[:success] = t("notice.item_save_success", :item => User.model_name.human)
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
      Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => t("log.item_verify", :item => User.model_name.human, :name => @user.username))
      flash[:success] = t("notice.item_save_success", :item => User.model_name.human)
    end
    redirect_to :action => "edit", :id => @user    
  end  

  def send_verification_email
    verification = UserVerification.find_by_user_id(@user.id)
    verification = UserVerification.create(:user_id => @user.id, :code => UserVerification.generate_code) if !verification # if none found, create new verification email 
    if verification
      url = url_for(:action => "verify", :controller => "user", :id => verification.id, :code =>  verification.code, :only_path => false)
      Emailer.deliver_verification_email(@user.email, verification, url)
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_email_sent", :item => UserVerification.model_name.human, :name => @user.username))                                                  
      flash[:success] =  t("log.item_email_sent", :item => UserVerification.model_name.human, :name => @user.username)
    else
      flash[:failure] = t("notice.item_not_found", :item => UserVerification.model_name.human)
    end 
    redirect_to :action => "edit", :controller => "users", :id => @user
  end

 def change_avatar
   require "RMagick"
     if !params[:file].nil? && !params[:file].blank?    #from their computer
      filename = params[:file].original_filename
      file_dir = "#{Rails.root.to_s}/public/images/avatars" 
      acceptable_file_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
      if Uploader.check_file_extension(:filename => filename, :extensions => acceptable_file_extensions)
       image = Magick::Image.from_blob(params[:file].read).first    # read in image binary
       image.crop_resized!( 100, 100 ) # Resize image
       image.write("#{file_dir}/#{@user.id.to_s}.png") # write the file
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log =>  t("log.user_account_item_save", :item => t("single.avatar")))                                                   
       flash[:success] = t("notice.save_success")     
      else
       flash[:failure] = t("notice.invalid_file_extensions", :item => Image.model_name.human, :acceptable_file_extensions => acceptable_file_extensions)      
      end
     else # they didn't select an image
       flash[:failure] = t("notice.item_forgot_to_select", :item => Image.model_name.human)      
     end

   redirect_to :action => "edit", :id => @user
 end

end
