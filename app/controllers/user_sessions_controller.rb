# user_sessions_controller.rb
class UserSessionsController < ApplicationController 
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => :destroy
  skip_filter :check_public_access, :only => [:new, :create]
  
  def new
    flash[:success] = t("label.log_in_redirect_message") if params[:redirect_to].present?
    @user_session = UserSession.new
    @setting[:meta_title] << t("label.log_in")
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      @logged_in_user = @user_session.record
      @user_session.record.user_info.update_attribute(:forgot_password_code, nil) # clear password recovery code      
      flash[:success] = t("notice.user_login_success") 
      
      # Handle special redirect
      if params[:redirect_to].present?
        uri = URI(CGI::unescape(params[:redirect_to]))
        
        # force local-only redirect
        uri.host = nil
        uri.scheme = nil  

        redirect_to uri.to_s
      else
        redirect_to user_home_path  # send them back to original request 
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