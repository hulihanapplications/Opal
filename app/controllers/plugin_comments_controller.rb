class PluginCommentsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Comment"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
     flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div><br>"
     redirect_to :action => "view", :controller => "items", :id => @item.id       
   end
 end
   
 def create # this is the only create action that doesn't require that the item is editable by the user
   if simple_captcha_valid?
     @item = Item.find(params[:id])
     if @item.is_viewable_for_user?(@logged_in_user)  # proceed if the user is allowed to see it(or if anonymous comments are on)
       if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?
         @comment = PluginComment.new(params[:comment])
         if @logged_in_user.id != 0 # if the user is not anonymous
           @comment.user_id = @logged_in_user.id # set comment user id
         else # a visitor is leaving the comment.
         end 
         
         # Set Approval
         @comment.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
         
         @comment.item_id = @item.id
         if @comment.save
          Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Left a #{@plugin.title}.") if @logged_in_user.id != 0
          Log.create(:item_id => @item.id,  :log_type => "new", :log => "A visitor at #{request.env["REMOTE_ADDR"]} left a #{@plugin.title}.") if @logged_in_user.id == 0
          
          flash[:notice] = "<div class=\"flash_success\">New #{@plugin.title} added. Thanks for your input!</div>"
          flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !@comment.is_approved?
         else # fail saved 
          flash[:notice] = "<div class=\"flash_failure\">This #{@plugin.title} could not be added! Here's why:<br>#{print_errors(@comment)}</div>"
         end
       else # Improper Permissions  
            flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div><br>"        
       end 
     else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
          flash[:notice] = "<div class=\"flash_failure\">Sorry, this item isn't viewable by you.</div><br>"        
     end 
   else # captcha failed'
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you entered in the wrong Anti-Spam code.</div><br>"
   end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end 
 
 def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @comment = PluginComment.find(params[:comment_id])
     if @comment.destroy
       Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted a #{@plugin.title}(#{@comment.id}).") 
       flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} deleted!</div>"     
     else # fail saved 
       flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} could not be deleted!</div>"     
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div><br>"        
   end      
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end
 
 def change_approval
    @comment = PluginComment.find(params[:comment_id])    
    if  @comment.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@comment.user.username}." if @comment.user_id
      log_msg = "Unapproved #{@plugin.title} from #{@comment.anonymous_name}." if @comment.anonymous_name       
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@comment.user.username}." if @comment.user_id
      log_msg = "Approved #{@plugin.title} from #{@comment.anonymous_name}." if @comment.anonymous_name             
    end
    
    if @comment.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div><br>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div><br>"
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end
end
