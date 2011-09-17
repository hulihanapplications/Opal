class UserController < ApplicationController
  # this controller may/may not contain anything, but each controller under app/controllers/user/* inherits from this.
  before_filter :authenticate_user, :except =>  [:login, :create_account, :register, :user_valid, :create_comment, :forgot_password, :recover_password]
  before_filter :enable_user_menu, :except => [:register, :create_account]  # show_user_menu
  before_filter :enable_sorting, :only => [:items] # prepare sort variables & defaults for sorting

  def index
    @latest_logs = Log.find(:all, :limit => 5, :conditions => Log.get_search_conditions(:user => @logged_in_user))
    @items = Item.find(:all, :select => "id", :order => "created_at DESC", :conditions => ["user_id = ?", @logged_in_user.id])
    @plugins = Plugin.enabled
  end

  def create_account
    if @setting[:allow_user_registration]
      @user = User.new(params[:user]) # always remember that ANYONE can override bulk assignment

      if human? || session[:omniauth]
        @user.apply_omniauth(session[:omniauth]) if session[:omniauth] # load omniauth data
        @user.registered_ip = request.env["REMOTE_ADDR"]
        @user.is_admin = "0"

        if @user.save # creation successful
          flash[:success] =  [t("notice.user_account_create_success")]
          log(:log_type => "create", :target => @user, :user_id => @user.id)
          if session[:omniauth] # saved omniauth data
            @authentication = @user.authentications.new(:provider => session[:omniauth]['provider'], :uid => session[:omniauth]['uid'])
            flash[:success] << " " + t("notice.account_connected_to", :to => @authentication.provider) if @authentication.save
            session[:omniauth] = nil
          end

          sign_in_and_redirect(@user)
        else  #save failed
          flash[:failure] = t("notice.user_account_create_failure")
          render :action => "register"
        end
      else # captcha failed
        flash[:failure] = I18n.translate("humanizer.validation.error")
        render :action => "register"
      end
    end
  end

  def register
    if @setting[:allow_user_registration]
      @user = User.new
      @user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    else # users not allowed to register
      flash[:failure] =  t("notice.invalid_permissions")
      redirect_to root_path
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

  def user_valid
    user = User.new(:username => params[:username], :email => "none@#{String.random(:length => 12).to_s}.com")
    render :text => {:valid => user.valid?, :errors => user.errors[:username]}.to_json #username_found.nil?
  end

  def settings
    @user = @logged_in_user
  end

  def forgot_password
    @user = User.find(:first, :conditions => ["email = ?", params[:user][:email]])
    if @user
      forgot_password_code = UserInfo.generate_forgot_password_code
      if @user.user_info.update_attribute(:forgot_password_code, forgot_password_code)
        Emailer.password_recovery_email(@user, url_for(:action => "recover_password", :controller => "user", :id => @user.id, :code => forgot_password_code, :only_path => false)).deliver
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
