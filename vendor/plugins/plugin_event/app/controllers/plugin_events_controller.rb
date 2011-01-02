class PluginEventsController < ApplicationController
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Event"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
     flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div><br>"
     redirect_to :action => "view", :controller => "items", :id => @item.id       
   end
 end
  
  def create
     plugin = Plugin.find(:first, :conditions => ["name = ?", "Event"])
      if plugin.is_enabled? # check to see if the plugin is enabled 
         @event = PluginEvent.new(params[:event])
         @event.user_id = @logged_in_user.id
         @event.item_id = @item.id
         if @event.save
          flash[:notice] = "<div class=\"flash_success\">New #{plugin.title} added successfully!</div><br>"
         else # fail saved 
          flash[:notice] = "<div class=\"flash_failure\">This #{plugin.title} could not be added! Here's why:<br>"
          @event.errors.each do |key,value|
            flash[:notice] << "#{key} #{value}<br>" #print out any errors!
          end
          flash[:notice] << "</div><br>"
         end 
      else # Item Object Not enabled
          flash[:notice] = "<div class=\"flash_failure\">Sorry, #{plugin.title}s aren't enabled.</div><br>"
      end
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end 
 
 def delete
   plugin = Plugin.find(:first, :conditions => ["name = ?", "Event"])
   if plugin.is_enabled? # check to see if the plugin is enabled 
     @event = PluginEvent.find(params[:event_id])
     if @event.destroy
       flash[:notice] = "<div class=\"flash_success\">#{plugin.title} deleted!</div>"     
     else # fail saved 
       flash[:notice] = "<div class=\"flash_failure\">#{plugin.title} could not be deleted!</div>"     
     end
   else # Item Object Not enabled
      flash[:notice] = "<div class=\"flash_failure\">Sorry, #{plugin.title}s aren't enabled.</div><br>"
   end 
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end
 
 def rss
   if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @event = PluginEvent.find(params[:event_id])
     if @item.is_viewable_for_user?(@logged_in_user) # make sure user can see the item   
       @site_url = request.env["HTTP_HOST"]
       @posts = PluginEventPost.find(:all, :conditions => ["plugin_event_id = ?", @event.id], :limit => 30) 
       render :layout => false
     else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
       flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot view this #{@plugin.title}.</div>"   
       redirect_to :action => "index", :category => "browse"
     end  
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot view #{@plugin.title}s.</div><br>"        
   end   
 end   

 def change_approval
    @event = PluginEvent.find(params[:event_id])    
    if @event.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@event.user.username}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@event.user.username}."
    end
    
    if @event.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div><br>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div><br>"
    end
    redirect_to :action => "view", :controller => "items", :id => @item
  end
 
end  
