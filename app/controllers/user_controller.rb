class UserController < ApplicationController
 # this controller may/may not contain anything, but each controller under app/controllers/user/* inherits from this.
 before_filter :authenticate_user, :except =>  [:login, :create_account, :register, :check_username, :create_comment, :forgot_password, :recover_password]
 before_filter :enable_user_menu, :except => [:register]  # show_user_menu
 before_filter :enable_sorting, :only => [:items] # prepare sort variables & defaults for sorting

 
 include SimpleCaptcha::ControllerHelpers
   
 def index
    @latest_logs = Log.find(:all, :limit => 5, :conditions => Log.get_search_conditions(:user => @logged_in_user))
    @items = Item.find(:all, :select => "id", :order => "created_at DESC", :conditions => ["user_id = ?", @logged_in_user.id])
    @plugins = Plugin.enabled
 end


 # Create a New account
 def create_account
  if Setting.get_setting_bool("allow_user_registration")
    if request.post?
     if simple_captcha_valid?  
        @user = User.new(params[:user]) # always remember that ANYONE can override bulk assignment
        @user.registered_ip = request.env["REMOTE_ADDR"]
        @user.is_admin = "0"   

        if Setting.get_setting_bool("email_verification_required") && !@user.is_admin? # if verification required?
          @user.is_verified = "0"  
        else # not required, verify user
          @user.is_verified = "1"
        end
        
        flash[:notice] = ""
        if @user.save # creation successful
         Log.create(:user_id => @user.id, :log_type => "new", :log =>  t("log.user_account_create", :title => @setting[:title]))
         Emailer.deliver_new_user_notification(@user, url_for(:action => "user", :controller => "browse", :id => @user)) if Setting.get_setting_bool("new_user_notification")         
         flash[:success] =  t("notice.user_account_create_success")

         if @user.is_verified? # check verification
           # Automatically log in user
           session[:user_id] = @user.id 
           @logged_in_user = @user               
           flash[:success] +=  " " + t("notice.user_login_success")
         else # they need to verify their account.
           verification = UserVerification.create(:user_id => @user.id, :code => UserVerification.generate_code)
           url = url_for(:action => "verify", :controller => "user", :id => verification.id, :code =>  verification.code, :only_path => false)
           Emailer.deliver_verification_email(@user.email, verification, url) # send verification email
           flash[:info] =  t("notice.user_account_needs_verification")         
         end 
         redirect_to :action => "index", :controller => "/browse"        
        else  #save failed
         flash[:failure] = t("notice.user_account_create_failure")
         redirect_to :action => "register", :controller => "user"
        end
     else # captcha failed
        flash[:failure] =  t("notice.invalid_captcha")  #print out any errors!
        redirect_to :action => "register", :controller => "user"
     end
   end
  else # users can't register.
    flash[:failure] =  t("notice.invalid_permissions")  
    redirect_to :action => "index", :controller => "/browse"
  end 
 end


 # Authentication Functions
  def login
    if request.post?
       # User ID will return valid if they log in correctly, if not, nil is returned 
       session[:user_id] = User.authenticate(params[:user][:username], params[:user][:password])
       if session[:user_id] # if login successful
         @logged_in_user = User.find(session[:user_id]) # retrieve the fresh user from DB, so we can update login stats
         @logged_in_user.user_info.update_attribute(:forgot_password_code, nil) # clear password recovery code
         flash[:success] = t("notice.user_login_success")
         @logged_in_user.update_attribute(:last_login, Time.now.strftime("%Y-%m-%d %H:%M:%S")) # update last login time
         @logged_in_user.update_attribute(:last_login_ip, Time.now.strftime(request.env["REMOTE_ADDR"])) # update last login ip

         if session[:original_uri] # go back to the user's original destination
           redirect_to session[:original_uri]
           session[:original_uri] = nil # clear out original destination
         else # no original destination set, go to user home
           redirect_to :action => "index", :controller => "user"
         end         
       else # authentication failed!
         flash[:failure] = t("notice.user_login_failure")
         redirect_to :action => "login", :controller => "browse"     
       end
    end
  end

  def logout
    session[:user_id] = nil
    @logged_in_user = nil
    reset_session
    flash[:success] = t("notice.user_logout_success")
    redirect_to  :action => "index", :controller => "/browse"
  end
 
  def register
    @setting[:load_prototype] = true # load prototype js in layout 
  end
 
  def verify
    @user_verification = UserVerification.find(params[:id])
    if params[:code] == @user_verification.code 
      if @user_verification.is_verified == "0" # they haven't verified yet. 
        @user = User.find(@user_verification.user_id)
        @user_verification.update_attributes(:referrer => request.env['HTTP_REFERER'], :ip => request.env['REMOTE_ADDR'], :verification_date => Time.now, :is_verified => "1")
        @user.update_attribute(:is_verified, "1") # make user verified
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.user_account_verify"))                                              
        flash[:success] = t("notice.user_account_verify_success")       
      else # they already verified
        flash[:failure] = t("notice.user_account_verify_failure") 
      end       
    else # code doesn't match
      flash[:failure] = t("notice.user_account_verify_failure") 
    end        
    redirect_to  :action => "index", :controller => "/browse"    
  end
 
  def check_username
   username_found = User.find(:first, :conditions => ["username = ?", params[:username]], :select => :username)
   if username_found # username taken
    render :text => "<div class=\"flash_failure\">#{t("label.username_taken")}</div>"
   else # username not taken
    render :text => "<div class=\"flash_success\">#{t("label.username_available")}</div>"
   end
   #render :layout => false
  end




def change_password
  if request.post?
    @user = @logged_in_user    
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log =>  t("log.user_account_object_save", :object => User.human_attribute_name(:password)))
      flash[:success] = t("notice.save_success")
      redirect_to :action => "settings"
    else # save failed
      flash[:failure] = t("notice.save_failure")
      render :action => "settings"
    end    
  end
end

 def change_avatar
   @user = @logged_in_user   
   if !@user.use_gravatar? && params[:use_gravatar] == "1" # They are enabling gravatar
     @user.user_info.update_attribute(:use_gravatar, params[:use_gravatar])
     flash[:success] = t("notice.save_success")     
   elsif @user.use_gravatar? && params[:use_gravatar] == "0" # They are diabling gravatar
     @user.user_info.update_attribute(:use_gravatar, params[:use_gravatar])
     flash[:success] = t("notice.save_success")     
   else # they are uploading a new photo
     if params[:file] != ""   #from their computer
      filename = params[:file].original_filename
      file_dir = "#{RAILS_ROOT}/public/images/avatars" 
      acceptable_file_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
      if Uploader.check_file_extension(:filename => filename, :extensions => acceptable_file_extensions)
       image = Magick::Image.from_blob(params[:file].read).first    # read in image binary
       image.crop_resized!( 100, 100 ) # Resize image
       image.write("#{file_dir}/#{@user.id.to_s}.png") # write the file
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log =>  t("log.user_account_object_save", :object => t("single.avatar")))                                                   
       flash[:success] = t("notice.save_success")     
      else
       flash[:failure] = t("notice.invalid_file_extensions", :object => Image.human_name, :acceptable_file_extensions => acceptable_file_extensions)      
      end
     else # they didn't select an image
       flash[:failure] = t("notice.object_forgot_to_select", :object => Image.human_name)      
     end
   end

   redirect_to :action => "settings"

 end
 
 def update_account
   @user = @logged_in_user
   #@user_info = @user.user_info
     params[:user][:username] = @user.username # make username unchangeable
     params[:user][:email] = @user.email # make email unchangeable
     if @user.user_info.update_attributes(params[:user_info]) && @user.update_attributes(params[:user])       
       Log.create(:user_id => @logged_in_user.id, :log_type => "update",  :log =>  t("log.user_account_object_save", :object => UserInfo.human_name))                                              
       flash[:success] = t("notice.save_success")
       redirect_to :action => "settings"  
     else 
       render :action => "settings"
     end
 end

  def items
    #render :layout => false
    @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => Item.sort_order(params[:sort]) , :conditions => ["user_id = ?", @logged_in_user.id]
    @plugins = Plugin.enabled 
  end  

  def settings
    @user = @logged_in_user
  end  


  def forgot_password 
    @user = User.find(:first, :conditions => ["email = ?", params[:user][:email]])
    if @user
      forgot_password_code = UserInfo.generate_forgot_password_code
      if @user.user_info.update_attribute(:forgot_password_code, forgot_password_code)
        Emailer.deliver_password_recovery_email(@user, url_for(:action => "recover_password", :controller => "user", :id => @user.id, :code => forgot_password_code, :only_path => false))
        flash[:success] = t("notice.user_account_recover_password_instructions")
      end
    else  # user not found
      flash[:failure] = t("notice.object_not_found", :object => User.human_name)
    end
    redirect_to :action => "login", :controller => "browse"
  end

  def recover_password
    @user = User.find(params[:id])
    if params[:code] == @user.user_info.forgot_password_code
       @user.user_info.update_attribute(:forgot_password_code, nil) # reset password recovery code
       new_password = UserInfo.generate_password
       if @user.update_attribute(:password, new_password) # reset password
         Log.create(:user_id => @user.id, :log_type => "system", :log =>  t("log.object_recover", :object => User.human_attribute_name(:password)))
         flash[:success] =  t("notice.user_account_recover_password_success", :new_password => new_password)
       end
    else
      flash[:failure] = t("notice.object_invalid", :object => UserInfo.human_attribute_name(:forgot_password_code))     
    end
    redirect_to :action => "login", :controller => "browse"    
  end
  
end
