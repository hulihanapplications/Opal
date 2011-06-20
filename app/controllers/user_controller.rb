class UserController < ApplicationController
 # this controller may/may not contain anything, but each controller under app/controllers/user/* inherits from this.
 before_filter :authenticate_user, :except =>  [:login, :create_account, :register, :user_available, :create_comment, :forgot_password, :recover_password]
 before_filter :enable_user_menu, :except => [:register, :create_account]  # show_user_menu
 before_filter :enable_sorting, :only => [:items] # prepare sort variables & defaults for sorting

 
 include SimpleCaptcha::ControllerHelpers
   
 def index
    @latest_logs = Log.find(:all, :limit => 5, :conditions => Log.get_search_conditions(:user => @logged_in_user))
    @items = Item.find(:all, :select => "id", :order => "created_at DESC", :conditions => ["user_id = ?", @logged_in_user.id])
    @plugins = Plugin.enabled
 end


 # Create a New account
 def create_account
  if @setting[:allow_user_registration]
    if request.post?
     @user = User.new(params[:user]) # always remember that ANYONE can override bulk assignment
     if simple_captcha_valid?  
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
         render :action => "register"
        end
     else # captcha failed
        flash[:failure] =  t("notice.invalid_captcha")  #print out any errors!
        render :action => "register"
     end
   end
  else # users can't register.
    flash[:failure] =  t("notice.invalid_permissions")  
    redirect_to :action => "index", :controller => "/browse"
  end 
end

  def register
    if @setting[:allow_user_registration]
      @user = User.new
    else # users not allowed to register
      flash[:failure] =  t("notice.invalid_permissions")  
      redirect_to :action => "index", :controller => "browse"    
    end 
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
 
  def user_available
   username_found = User.find(:first, :conditions => ["username = ?", params[:username]], :select => :username)
   render :json => username_found.nil?
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
      flash[:failure] = t("notice.item_not_found", :item => User.model_name.human)
    end
    redirect_to :action => "login", :controller => "browse"
  end

  def recover_password
    @user = User.find(params[:id])
    if params[:code] == @user.user_info.forgot_password_code
       @user.user_info.update_attribute(:forgot_password_code, nil) # reset password recovery code
       new_password = UserInfo.generate_password
       if @user.update_attribute(:password, new_password) # reset password
         Log.create(:user_id => @user.id, :log_type => "system", :log =>  t("log.item_recovered", :item => User.human_attribute_name(:password)))
         flash[:success] =  t("notice.user_account_recover_password_success", :new_password => new_password)
       end
    else
      flash[:failure] = t("notice.item_invalid", :item => UserInfo.human_attribute_name(:forgot_password_code))     
    end
    redirect_to :action => "login", :controller => "browse"    
  end
  
end
