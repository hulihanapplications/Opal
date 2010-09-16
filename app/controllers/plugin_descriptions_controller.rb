class PluginDescriptionsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 uses_tiny_mce :only => [:new, :edit]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.
 
 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Description"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
      flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div><br>"
      redirect_to :action => "view", :controller => "items", :id => @item.id        
   end
 end

 
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
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "create", :log => "Added #{@plugin.title}: #{@description.title}")             
      flash[:notice] = "<div class=\"flash_success\">New #{@plugin.title}: <b>#{@description.title}</b> added!</div>"
      flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !@description.is_approved?
     else # fail saved 
      flash[:notice] = "<div class=\"flash_failure\">This #{@plugin.title} could not be added!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"        
   end   
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end
 
  def update
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?
     @description = PluginDescription.find(params[:description_id])
     @description.title = params[:description][:title]
     @description.content = sanitize(params[:description][:content])
     if @description.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => "Updated #{@plugin.title}: #{@description.title}(#{@description.id})")                    
      flash[:notice] =  "<div class=\"flash_success\">Your changes to <b>#{@description.title}</b> have been saved.</div>"
     else # fail saved 
       flash[:notice] = "<div class=\"flash_success\">Update Failed!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot update #{@plugin.title}s.</div><br>"        
   end    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end
  
  def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @description = PluginDescription.find(params[:description_id])
     if @description.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted #{@plugin.title}: #{@description.title}(#{@description.id})")                           
      flash[:notice] = "<div class=\"flash_success\">#{@description.title} Deleted!</div>"
     else # fail saved 
       flash[:notice] = "<div class=\"flash_success\">Delete Failed!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div><br>"        
   end   
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end  

 def change_approval
    @description = PluginDescription.find(params[:description_id])    
    if  @description.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@description.user.username}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@description.user.username}."
    end
    
    if @description.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div><br>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div><br>"
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end
 
  def new 
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions
      @description = PluginDescription.new
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div><br>"
        redirect_to :action => "view", :controller => "items", :id => @item.id     
   end    
  end
 
  def edit
     if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?
       @description = PluginDescription.find(params[:description_id])
     else # Improper Permissions  
          flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot update #{@plugin.title}s.</div><br>"
          redirect_to :action => "view", :controller => "items", :id => @item.id                 
     end    
  end
end
