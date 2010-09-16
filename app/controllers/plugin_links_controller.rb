class PluginLinksController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Link"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
      flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div>"
      redirect_to :action => "view", :controller => "items", :id => @item.id         
   end
 end


 
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
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Created #{@plugin.title}: #{@link.title}.")                        
      flash[:notice] = "<div class=\"flash_success\">New #{@plugin.title}: <b>#{@link.title}</b> added!</div>"
      flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !@link.is_approved?       
     else # fail saved 
      flash[:notice] = "<div class=\"flash_failure\">This #{@plugin.title} could not be added!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"        
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end
 
  def update
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           

     @link = PluginLink.find(params[:link_id])
     if @link.update_attribute(:title, params[:link_title]) && @link.update_attribute(:url, params[:link_url])
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => "#{@plugin.title} Updated: #{@link.title}.")                               
      flash[:notice] = "<div class=\"flash_success\"><a href=\"#{@link.url}\">#{@link.title}</a> Updated!</div>"
     else # fail saved 
       flash[:notice] = "<div class=\"flash_failure\">Update Failed!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot update #{@plugin.title}s.</div>"        
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end
  
  def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           

     @link = PluginLink.find(params[:link_id])
     if @link.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "#{@plugin.title} Deleted: #{@link.title}.")                                      
      flash[:notice] = "<div class=\"flash_success\"><b>#{@link.title}</b> Deleted!</div>"
     else # fail saved 
       flash[:notice] = "<div class=\"flash_success\">Delete Failed!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div>"        
   end  

   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end  
 
 def change_approval
    @link = PluginLink.find(params[:link_id])    
    if  @link.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@link.user.username}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@link.user.username}."
    end
    
    if @link.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div>"
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end  
end
