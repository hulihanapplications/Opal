class PluginDescriptionsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 uses_tiny_mce :only => [:new, :edit]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.
 
 
  def create
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions
     @description = PluginDescription.new
     @description.title = params[:description][:title]
     @description.content = sanitize(params[:description][:content])
     @description.user_id = @logged_in_user.id
     @description.item_id = @item.id
     
     # Set Approval
     @description.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
           
     if @description.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "create", :log => t("log.object_create", :object => @plugin.human_name, :name => @description.title))             
      flash[:success] = t("notice.object_create_success", :object => @plugin.human_name)
      flash[:success] += t("notice.object_needs_approval", :object => @plugin.human_name) if !@description.is_approved?
     else # fail saved 
      flash[:failure] = t("notice.object_create_failure", :object => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")    
   end   
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end
 
  def update
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?
     @description = PluginDescription.find(params[:description_id])
     @description.title = params[:description][:title]
     @description.content = sanitize(params[:description][:content])
     if @description.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.object_save", :object => @plugin.human_name, :name => @description.title))                    
      flash[:success] =  t("notice.object_save_success", :object => @plugin.human_name)
     else # fail saved 
       flash[:success] = t("notice.object_save_failure", :object => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] =  t("notice.invalid_permissions")        
   end    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end
  
  def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @description = PluginDescription.find(params[:description_id])
     if @description.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.object_delete", :object => @plugin.human_name, :name => @description.title))                           
      flash[:success] = t("notice.object_delete_success", :object => @plugin.human_name)
     else # fail saved 
       flash[:success] = t("notice.object_delete_failure", :object => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] =  t("notice.invalid_permissions")        
   end   
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
 end  

 def change_approval
    @description = PluginDescription.find(params[:description_id])    
    if  @description.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.object_unapprove", :object => @plugin.human_name, :name => truncate(@description.content, :length => 20))
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.object_approve", :object => @plugin.human_name, :name => truncate(@description.content, :length => 20))
    end
    
    if @description.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.object_approve_success", :object => @plugin.human_name) 
    else
      flash[:failure] = t("notice.object_save_failure", :object => @plugin.human_name)
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end
 
  def new 
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions
      @description = PluginDescription.new
   else # Improper Permissions  
      flash[:failure] = t("notice.invalid_permissions")
      redirect_to :action => "view", :controller => "items", :id => @item.id     
   end    
  end
 
  def edit
     if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?
       @description = PluginDescription.find(params[:description_id])
     else # Improper Permissions  
          flash[:failure] = t("notice.invalid_permissions")
          redirect_to :action => "view", :controller => "items", :id => @item.id                 
     end    
  end
end
