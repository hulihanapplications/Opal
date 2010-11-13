class PluginLinksController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 



 
  def create
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions               
     @link = PluginLink.new
     @link.title = params[:link_title]
     @link.url = params[:link_url]
     @link.user_id = @logged_in_user.id
     @link.item_id = @item.id
   
     # Set Approval
     @link.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
        
     if @link.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.object_create", :object => @plugin.human_name, :name => @link.title))                        
      flash[:success] =  t("notice.object_create_success", :object => @plugin.human_name)
      flash[:notice] +=  t("notice.object_needs_approval", :object => @plugin.human_name) if !@link.is_approved?       
     else # fail saved 
      flash[:failure] =  t("notice.object_create_failure", :object => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")            
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end
 
  def update
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           

     @link = PluginLink.find(params[:link_id])
     if @link.update_attribute(:title, params[:link_title]) && @link.update_attribute(:url, params[:link_url])
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log =>  t("log.object_save", :object => @plugin.human_name, :name => @link.title))                               
      flash[:success] =  t("notice.object_save_success", :object => @plugin.human_name)
     else # fail saved 
       flash[:failure] =  t("notice.object_save_failure", :object => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")            
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end
  
  def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           

     @link = PluginLink.find(params[:link_id])
     if @link.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log =>  t("log.object_delete", :object => @plugin.human_name, :name => @link.title))                                      
      flash[:success] =  t("notice.object_delete_failure", :object => @plugin.human_name)
     else # fail saved 
       flash[:failure] =  t("notice.object_delete_failure", :object => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")            
   end  

   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end  
 
 def change_approval
    @link = PluginLink.find(params[:link_id])    
    if  @link.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.object_unapprove", :object => @plugin.human_name, :name => @link.title)
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.object_approve", :object => @plugin.human_name, :name => @link.title)
    end
    
    if @link.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.object_approve_success", :object => @plugin.human_name) 
    else
      flash[:failure] =  t("notice.object_save_failure", :object => @plugin.human_name)
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end  
end
