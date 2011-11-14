class UsersController < ApplicationController
  before_filter :enable_sorting, :only => [:show] # prepare sort variables & defaults for sorting
  before_filter :authenticate_user, :except => [:show] # must be logged in
  before_filter :find_user, :except => [:index, :create, :new, :show, :verification_required]
  before_filter :authenticate_admin, :except => [:change_password, :change_avatar, :update, :edit, :show, :verification_required] # make sure logged in user is an admin
  before_filter :enable_admin_menu, :except => [:change_password, :change_avatar, :update, :edit, :show, :verification_required]  # show admin menu 
  before_filter :protect_against_self, :only => [:delete, :toggle_user_disabled, :toggle_user_verified] 
  
  def find_user
    if @logged_in_user.is_admin?
      @user = User.find(params[:id])
    else # not admin ... select self
      @user = @logged_in_user 
    end 
  end 
  
  def protect_against_self # prevent logged in user from performing restrictive actions against themselves 
    if defined?(@user)
      if @user.id == @logged_in_user.id # selected user is same as logged in user
        flash[:failure] = t("notice.invalid_permissions")
        redirect_to users_path 
      else # not the same user, proceed
        # proceed
      end 
    end 
  end   
  
  def index
    @setting[:meta_title] << User.model_name.human.pluralize 
    @users = User.paginate :page => params[:page], :per_page => 100, :order => "username ASC"
  end
  
  def create
    @user = User.new(params[:user])
    if @logged_in_user.is_admin? # handle protected attributes
      @user.is_admin = params[:user][:is_admin]
      @user.group_id = params[:group_id]  
    end
    
    @user.is_verified = "1"
        
    if @user.save 
      flash[:success] = t("notice.item_create_success", :item => User.model_name.human)      
      log(:log_type => "create", :target => @user)
      redirect_to users_path      
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
      params[:user][:created_at] = @user.created_at  
    end                    
    
    if @user.update_attributes(params[:user]) && @user_info.update_attributes(params[:user_info])        
      @user.update_attribute(:is_admin, params[:user][:is_admin]) if @logged_in_user.is_admin?
      log(:target => @user, :log_type => "update")
      flash[:success] = t("notice.save_success") 
      redirect_to edit_user_path(@user)
    else
      render :action => "edit"      
    end
  end
  
  def destroy 
    if @user.id == @logged_in_user.id.to_i # trying to delete the user they're logged in as.
      flash[:failure] = t("notice.invalid_permissions")
    else
      log(:target => @user, :log_type => "destroy")
      flash[:success] = t("notice.item_delete_success", :item => User.model_name.human) 
      @user.destroy
    end
    redirect_to users_path 
  end
  
  def change_password
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      log(:target => @user, :log_type => "update")
      flash[:success] = t("notice.save_success") 
      redirect_to edit_user_path(@user)
    else
      flash[:failure] = t("notice.save_failure") 
      render :action => "edit"
    end
  end
  
  def edit
    @user_info = @user.user_info
    @user.id == @logged_in_user.id ? enable_user_menu : enable_admin_menu 
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
      log(:target => @user, :log_type => "update", :log => log_msg)
    end
    redirect_to edit_user_path(@user) 
  end
  
  def toggle_user_verified
    if @user.is_verified?
      flag = "0"   # make unverified
    else # if user was unverified
      flag = "1"  # make verified
    end  
    if @user.update_attribute(:is_verified, flag)
      log(:target => @user, :log_type => "create", :log => t("log.item_verify", :item => User.model_name.human, :name => @user.username))
      flash[:success] = t("notice.item_save_success", :item => User.model_name.human)
    end
    redirect_to edit_user_path(@user)  
  end  
  
  def send_verification_email
    verification = UserVerification.find_by_user_id(@user.id)
    verification = UserVerification.create(:user_id => @user.id, :code => UserVerification.generate_code) if !verification # if none found, create new verification email 
    if verification && verification.send_email
      log(:target => @user, :log_type => "update", :log => t("log.item_email_sent", :item => UserVerification.model_name.human, :name => @user.username))                                                  
      flash[:success] =  t("log.item_email_sent", :item => UserVerification.model_name.human, :name => @user.username)
    else
      flash[:failure] = t("notice.item_not_found", :item => UserVerification.model_name.human)
    end 
    redirect_to edit_user_path(@user)
  end
  
  def change_avatar
    @user.avatar = params[:avatar]
    if @user.save
      log(:target => @user, :log_type => "update", :log => t("log.user_account_item_save", :item => t("single.avatar")))                                                   
      flash[:success] = t("notice.save_success")
    else 
      flash[:failure] = t("notice.save_failure")
    end

    redirect_to edit_user_path(@user)
  end
  
  def show
    @user = User.find(params[:id]) 
    @setting[:meta_title] << "#{@user.username}" 
    @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page], :order => Item.sort_order(params[:sort]), :conditions => ["user_id = ? and is_approved = '1' and is_public = '1'", @user.id ]
  end

  def verification_required
    @user = @logged_in_user
  end
end
