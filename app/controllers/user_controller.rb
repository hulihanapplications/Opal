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
         Log.create(:user_id => @user.id, :log_type => "new", :log => "#{@user.username}'s account created.")
         Emailer.deliver_new_user_notification(@user, url_for(:action => "user", :controller => "browse", :id => @user.id)) if Setting.get_setting_bool("new_user_notification")         
         flash[:notice] <<  "<div class=\"flash_success\">Your account was successfully created!"

         if @user.is_verified? # check verification
           # Automatically log in user
           session[:user_id] = @user.id 
           @logged_in_user = @user               
           flash[:notice] <<  "<br>You have been automatically logged in."
         else # they need to verify their account.
           verification = UserVerification.create(:user_id => @user.id, :code => UserVerification.generate_code)
           url = url_for(:action => "verify", :controller => "user", :id => verification.id, :code =>  verification.code, :only_path => false)
           Emailer.deliver_verification_email(@user.email, verification, url) # send verification email
           flash[:notice] <<  "<br><b>Your account needs to be verified before you can log in.</b><br>Please check your email for a verification link."         
         end 
         flash[:notice] << "</div>"
         redirect_to :action => "index", :controller => "/browse"        
        else  #save failed
         flash[:notice] << "<div class=\"flash_failure\">There was a problem creating your account! Here's why:<br>#{print_errors(@user)}</div>"
         redirect_to :action => "register", :controller => "user"
        end
     else # captcha failed
        flash[:notice] = "<div class=\"flash_failure\">You entered the wrong verification code!</div>" #print out any errors!
        redirect_to :action => "register", :controller => "user"
     end
   end
  else # users can't register.
    flash[:notice] = "<div class=\"flash_failure\">Sorry, Users aren't allowed to register right now.</div>" 
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
         flash[:notice] = "<div class=\"flash_success\">#{@logged_in_user.username} logged in successfully!</div>"
         @logged_in_user.update_attribute(:last_login, Time.now.strftime("%Y-%m-%d %H:%M:%S")) # update last login time
         @logged_in_user.update_attribute(:last_login_ip, Time.now.strftime(request.env["REMOTE_ADDR"])) # update last login ip

         if session[:original_uri] # go back to the user's original destination
           redirect_to session[:original_uri]
           session[:original_uri] = nil # clear out original destination
         else # no original destination set, go to user home
           redirect_to :action => "index", :controller => "user"
         end         
       else # authentication failed!
         flash[:notice] = "<div class=\"flash_failure\">Login failed!</div>"
         redirect_to :action => "login", :controller => "browse"     
       end
    end
  end

  def logout
    session[:user_id] = nil
    @logged_in_user = nil
    reset_session
    flash[:notice] = "<div class=\"flash_success\">You have been logged out! Have a nice day.</div>"
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
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Account verified.")                                              
        flash[:notice] = "<div class=\"flash_success\">Your account has been verified!<br>You can now log in.</div>"       
      else # they already verified
        flash[:notice] = "<div class=\"flash_failure\">This code has already been verified!</div>"
      end       
    else # code doesn't match
      flash[:notice] = "<div class=\"flash_failure\">This code does not match the verification record!</div>"
    end        
    redirect_to  :action => "index", :controller => "/browse"    
  end
 
  def check_username
   username_found = User.find(:first, :conditions => ["username = ?", params[:username]], :select => :username)
   if username_found # username taken
    render :text => "<div class=\"flash_failure\">This username is taken!</div>"
   else # username not taken
    render :text => "<div class=\"flash_success\">This username is available!</div>"
   end
   #render :layout => false
  end




 def change_password
  if request.post?
   @user = @logged_in_user
   if params[:user][:password].blank? # password is empty
     flash[:notice] = "<div class=\"flash_failure\">You didn't fill in a password box. Try Again!</div>"
   else #password is filled
    if params[:user][:password] != params[:user][:password_confirmation] # password doesn't match!
     flash[:notice] = "<div class=\"flash_failure\">Your passwords do not match!</div>"
    else#passwords match
     @user.password = params[:user][:password] 
     if @user.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Changed Password")
      flash[:notice] = "<div class=\"flash_success\">Password Changed Successfully!</div>"
     end
    end
   end
   redirect_to :action => "settings"
  end
 end

 def change_avatar
   @user = @logged_in_user   
   if !@user.use_gravatar? && params[:use_gravatar] == "1" # They are enabling gravatar
     @user.user_info.update_attribute(:use_gravatar, params[:use_gravatar])
     flash[:notice] = "<div class=\"flash_success\">Gravatar enabled!</div>"     
   elsif @user.use_gravatar? && params[:use_gravatar] == "0" # They are diabling gravatar
     @user.user_info.update_attribute(:use_gravatar, params[:use_gravatar])
     flash[:notice] = "<div class=\"flash_success\">Gravatar disabled!</div>"     
   else # they are uploading a new photo
     if params[:file] != ""   #from their computer
      filename = params[:file].original_filename
      file_dir = "#{RAILS_ROOT}/public/images/avatars" 
      if check_filename(filename) #the filename is valid
       image = Magick::Image.from_blob(params[:file].read).first    # read in image binary
       image.crop_resized!( 100, 100 ) # Resize image
       image.write("#{file_dir}/#{@user.id.to_s}.png") # write the file
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Uploaded a new avatar.")                                                   
       flash[:notice] = "<div class=\"flash_success\">Your new image has been uploaded. Thanks!</div> "     
      else
       flash[:notice] = "<div class=\"flash_failure\">#{params[:file].original_filename} upload failed! Please make sure that this is an image file, and that it ends in .png .jpg .jpeg .bmp or .gif </div> "
      end
     else # they didn't select an image
       flash[:notice] = "<div class=\"flash_failure\">You did not select an image!</div> "     
     end
   end

   redirect_to :action => "settings"

 end

 def update_user_info
  if request.post?
   @user = @logged_in_user
   #@user_info = @user.user_info
     if @user.user_info.update_attributes(params[:user_info])
     Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "User Info updated.")                                              
     flash[:notice] = "<div class=\"flash_success\">Info Changed Successfully!</div>"
     end
    redirect_to :action => "settings"
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
        flash[:notice] = "<div class=\"flash_success\">Instructions to recover your password have been sent to your email account.</div>"
      end
    else 
      flash[:notice] = "<div class=\"flash_failure\">Sorry, no account was found with the email address: #{params[:user][:email]}.</div>"
    end
    redirect_to :action => "login", :controller => "browse"
  end

  def recover_password
    @user = User.find(params[:id])
    if params[:code] == @user.user_info.forgot_password_code
       @user.user_info.update_attribute(:forgot_password_code, nil) # reset password recovery code
       new_password = "changeme"
       if @user.update_attribute(:password, new_password) # reset password
         Log.create(:user_id => @user.id, :log_type => "system", :log => "Password recovered.")
         flash[:notice] = "<div class=\"flash_success\">Your password has been changed to <b>#{new_password}</b>.<br>To change your password to something else, log into your account and click on the <b>My Settings</b> tab.</div>"
       end
    else
      flash[:notice] = "<div class=\"flash_failure\">Sorry, your password recovery code is incorrect.</div>"      
    end
    redirect_to :action => "login", :controller => "browse"    
  end
  
private
 def check_filename(filename)
  extensions = /.png|.jpg|.jpeg|.gif|.bmp|.tiff|.PNG|.JPG|.JPEG|.GIF|.BMP|.TIFF$/ #define the accepted regexs
  return extensions.match(filename)   # return false or true if matched
 end




end
