class AuthenticationsController < ApplicationController
  before_filter :authenticate_user, :only => [:index, :destroy]
  
  def index
    if @logged_in_user.is_admin?
      @user = params[:id].blank? ? @logged_in_user : User.find(params[:id])
      @authentications = @user.authentications
      @user.id != @logged_in_user.id ? enable_admin_menu : enable_user_menu
    else
      @authentications = @logged_in_user.authentications
      enable_user_menu      
    end
  end

  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    #flash[:info] = authentication.inspect
    if authentication # User is already registered with application      
      flash[:success] = t("notice.user_login_success") 
      sign_in_and_redirect(authentication.user)
    elsif @logged_in_user && !@logged_in_user.anonymous? # User is signed in but has not already authenticated with this social network          
      @authentication = @logged_in_user.authentications.new(:provider => omniauth['provider'], :uid => omniauth['uid'])
      #@logged_in_user.apply_omniauth(omniauth)
      #@logged_in_user.save       
      flash[:success] = t("notice.account_connected_to", :to => @authentication.provider) if @authentication.save
      redirect_to authentications_path
    else # User is new to this application      
      session[:omniauth] =  omniauth.except('extra')
      redirect_to :action => "create_account", :controller => "user" # create the user account
    end
  end
  
  def forget # erase saved session information
    session[:omniauth] = nil
    redirect_to :back
  end
  
  def confirm
    redirect_to :action => "create_account", :controller => "user"
  end
  
  def failure
    flash[:failure] = [t("notice.user_login_failure")]
    flash[:failure] << params[:message] if params[:message]
    #flash[:failure] << request.env['omniauth.auth'].inspect
    redirect_to login_path
  end
  
  def destroy
    if @logged_in_user.is_admin?
      @authentication = Authentication.find(params[:id])
    else 
      @authentication = @logged_in_user.authentications.find(params[:id])
    end
    @authentication.destroy
    flash[:success] =  t("notice.item_delete_success", :item => Authentication.model_name.human)   
    redirect_to authentications_url
  end
  
end