# user_sessions_controller.rb
class UserSessionsController < ApplicationController 
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => :destroy
  skip_before_filter :check_public_access, :only => [:new]
  
  def new
    @user_session = UserSession.new
    @setting[:meta_title] << t("label.log_in")
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      @logged_in_user = @user_session.record
      @user_session.record.user_info.update_attribute(:forgot_password_code, nil) # clear password recovery code      
      flash[:success] = t("notice.user_login_success") 
      
      if session[:original_uri] # is there a saved url? 
        redirect_to session[:original_uri]
        session[:original_uri] = nil
      else # no saved url
        redirect_to :action => "index", :controller => "user"
      end 
    else
      flash[:failure] = t("notice.user_login_failure") 
      render :action => 'new'
    end
  end
  
  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:success] = t("notice.user_logout_success")
    redirect_to root_url
  end
end