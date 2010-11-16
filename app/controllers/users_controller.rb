class UsersController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 

   def index
        @setting[:meta_title] = User.human_name.pluralize + " - " + t("section.title.admin").capitalize + " - " + @setting[:meta_title]
        #@users = User.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => "username ASC"
        @users = User.paginate :page => params[:page], :per_page => 100, :order => "username ASC"
        #@users = User.find(:all, :order => "username ASC")
        
        @latest_logins = User.find(:all, :limit => 5, :order => "last_login DESC")
   end
   
    def create
      @user = User.new(params[:user])
      if params[:is_admin] == "1"
        @user.is_admin = "1" # Make user an admin 
      end
      
      @user.is_verified = "1"
      
      if @user.save # save successful
        flash[:success] = t("notice.item_create_success", :item => User.human_name)      
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => t("log.item_create", :item => User.human_name, :name => @user.username))
        redirect_to :action => 'index'        
      else # creation failed
        render :action => "new"
      end
    end
  
   
   def update
      @user = User.find(params[:id])
      if params[:is_admin] == "1"
        @user.update_attribute("is_admin", "1") # Make user an admin 
      end
      
      if @user.update_attributes(params[:user])
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => User.human_name, :name => @user.username))
        flash[:success] = t("notice.item_save_success", :item => User.human_name) 
        redirect_to :action => "edit", :id => @user.id
      else
        render :action => "edit"      end
   end
  
   def delete 
     if params[:id].to_i == @logged_in_user.id.to_i # trying to delete the user they're logged in as.
       flash[:failure] = t("notice.invalid_permissions")
     else
       @user = User.find(params[:id])
       Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => User.human_name, :name => @user.username))
       flash[:success] = t("notice.item_delete_success", :item => User.human_name) 
       @user.destroy
     end
     redirect_to :action => 'index'
   end
   
  def change_password
    @user = User.find(params[:id]) 
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => User.human_name, :name => @user.username + "(#{User.human_attribute_name(:password)}: #{params[:user][:password]})"))
      flash[:success] = t("notice.save_success") 
    else
      flash[:failure] = t("notice.save_failure") 
    end
    redirect_to :action => "edit", :id => @user.id
  end

  def edit
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def toggle_user_disabled
    @user = User.find(params[:id])
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
      Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => t("log.item_verify", :item => User.human_name, :name => @user.username))
      flash[:success] = t("notice.item_save_success", :item => User.human_name)
    end
    redirect_to :action => "edit", :id => @user.id    
  end  

  def send_verification_email
    @user = User.find(params[:id])
    verification = UserVerification.find_by_user_id(@user.id)
    url = url_for(:action => "verify", :controller => "user", :id => verification.id, :code =>  verification.code, :only_path => false)
    verification = UserVerification.create(:user_id => @user.id, :code => UserVerification.generate_code) if !verification # if none found, create new verification email 
    Emailer.deliver_verification_email(@user.email, verification, url)
    Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_email_sent", :item => UserVerification.human_name, :name => @user.username))                                                  
    flash[:success] =  t("log.item_email_sent", :item => UserVerification.human_name, :name => @user.username)
    redirect_to :action => "edit", :controller => "users", :id => @user.id
  end

def update_user_info
  if request.post?
    @user = User.find(params[:id])
    #@user_info = @user.user_info
    if @user.user_info.update_attributes(params[:user_info])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("notice.item_save_success", :item => UserInfo.human_name))                                              
      flash[:success] = t("notice.item_save_success", :item => UserInfo.human_name)
      redirect_to :action => "edit", :controller => "users", :id => @user.id
    else 
      render :action => "edit"
    end
  end
end

def change_group
  @user = User.find(params[:id])
  @group = Group.find(params[:group_id])
  @user.group_id = @group.id
  if @user.save
    Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log =>  t("log.item_save", :item => User.human_name, :name => @user.username + "(#{User.human_attribute_name(:group_id)}: #{@group.name})"))                                              
    flash[:success] = t("notice.item_save_success", :item => User.human_name)
  end
  redirect_to :action => "edit", :controller => "users", :id => @user.id
end

end
