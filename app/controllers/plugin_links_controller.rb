class PluginLinksController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_view_permissions # can user view item?  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 before_filter :can_group_create_plugin, :only => [:create]
 before_filter :can_group_delete_plugin, :only => [:delete]   
  



 
  def create
   @link = PluginLink.new
   @link.title = params[:link_title]
   @link.url = params[:link_url]
   @link.user_id = @logged_in_user.id
   @link.item_id = @item.id
 
   # Set Approval
   @link.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
      
   if @link.save
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => @link.title))                        
    flash[:success] =  t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:notice] +=  t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@link.is_approved?       
   else # fail saved 
    flash[:failure] =  t("notice.item_create_failure", :item => @plugin.model_name.human)
   end
 
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
 
  def update
   @link = PluginLink.find(params[:link_id])
   if @link.update_attribute(:title, params[:link_title]) && @link.update_attribute(:url, params[:link_url])
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log =>  t("log.item_save", :item => @plugin.model_name.human, :name => @link.title))                               
    flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
   else # fail saved 
     flash[:failure] =  t("notice.item_save_failure", :item => @plugin.model_name.human)
   end
  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
  
  def delete
    @link = PluginLink.find(params[:link_id])
    if @link.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log =>  t("log.item_delete", :item => @plugin.model_name.human, :name => @link.title))                                      
      flash[:success] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)
    else # fail saved 
      flash[:failure] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)
    end
 
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end  
 
 def change_approval
    @link = PluginLink.find(params[:link_id])    
    if  @link.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.model_name.human, :name => @link.title)
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @plugin.model_name.human, :name => @link.title)
    end
    
    if @link.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @plugin.model_name.human)  
    else
      flash[:failure] =  t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end  
end
