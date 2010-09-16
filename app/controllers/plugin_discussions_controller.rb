class PluginDiscussionsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Discussion"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
     flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div><br>"
     redirect_to :action => "view", :controller => "items", :id => @item      
   end
 end


 def create # this is the only create action that doesn't require that the item is editable by the user
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @discussion = PluginDiscussion.new(params[:discussion])

     # Set Approval
     @discussion.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
           
     @discussion.item_id = @item.id
     if @discussion.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Created new #{@plugin.title}: #{@discussion.title}.")            
      flash[:notice] = "<div class=\"flash_success\">New #{@plugin.title} added. </div>"
      flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !@discussion.is_approved?      
     else # fail saved 
      flash[:notice] = "<div class=\"flash_failure\">This #{@plugin.title} could not be added! Here's why:<br>#{print_errors(@discussion)}</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"        
   end  
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => "#{@plugin.name}s" 
 end 
 
 def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @discussion = PluginDiscussion.find(params[:discussion_id])
     if @discussion.destroy
       Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted #{@plugin.title}: #{@discussion.title}(#{@discussion.id}).") 
       flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} deleted!</div>"     
     else # fail saved 
       flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} could not be deleted!</div>"     
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div>"        
   end       
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => "#{@plugin.name}s" 
 end
 
 def view
   if @item.is_viewable_for_user?(@logged_in_user)
     if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?

       @discussion = PluginDiscussion.find(params[:discussion_id])
       @posts = PluginDiscussionPost.paginate :page => params[:page], :per_page => 10, :conditions => ["plugin_discussion_id = ?", @discussion.id]
       @setting[:show_item_nav_links] = true # show nav links
     else # Improper Permissions  
          flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot view #{@plugin.title}s.</div>"        
     end        
   else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
     flash[:notice] = "<div class=\"flash_failure\">Sorry, this item isn't viewable by you.</div>"   
     redirect_to :action => "index", :category => "browse"
   end
 end
 
 def create_post
   @discussion = PluginDiscussion.find(params[:discussion_id])
   if @item.is_viewable_for_user?(@logged_in_user) # make sure user can see the item
     if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?     
       @post = PluginDiscussionPost.new(params[:post])
       @post.user_id = @logged_in_user.id
       @post.plugin_discussion_id = @discussion.id
       @post.item_id = @item.id 
       
       if @post.save
         Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Added a post to the #{@plugin.title}: #{@discussion.title}.")                   
         flash[:notice] = "<div class=\"flash_success\">Your Post has been added!</div>"
       else # fail saved 
        flash[:notice] = "<div class=\"flash_failure\">This Post could not be added! Here's why:<br>#{print_errors(@post)}</div>"     
       end
       redirect_to :action => "view", :controller => "plugin_discussions", :id => @item, :discussion_id => @discussion.id, :anchor => @post.id
     else # Improper Permissions  
          flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot view #{@plugin.title}s.</div><br>"        
     end         
   else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
     flash[:notice] = "<div class=\"flash_failure\">Sorry, this item isn't viewable by you.</div>" 
     redirect_to :action => "index", :category => "browse"     
   end 
 end
 
 def delete_post   
  if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
    @post = PluginDiscussionPost.find(params[:post_id])
    @discussion = @post.plugin_discussion
    if @post.destroy
       Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted a post(#{@post.id}) from the #{@plugin.title}: #{@discussion.title}.")                      
       flash[:notice] = "<div class=\"flash_success\">Post deleted!</div>"
    else # delete failed 
      flash[:notice] = "<div class=\"flash_failure\">This Post could not be deleted! Here's why:<br>#{print_errors(@post)}</div>"     
    end
     redirect_to :action => "view", :controller => "plugin_discussions", :id => @item, :discussion_id => @discussion.id
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title} posts.</div><br>"        
   end    
 end
 

 def rss
   if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @discussion = PluginDiscussion.find(params[:discussion_id])
     if @item.is_viewable_for_user?(@logged_in_user) # make sure user can see the item   
       @site_url = request.env["HTTP_HOST"]
       @posts = PluginDiscussionPost.find(:all, :conditions => ["plugin_discussion_id = ?", @discussion.id], :limit => 30) 
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
    @discussion = PluginDiscussion.find(params[:discussion_id])    
    if  @discussion.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@discussion.user.username}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@discussion.user.username}."
    end
    
    if @discussion.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div><br>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div><br>"
    end
    redirect_to :action => "view", :controller => "items", :id => @item
  end

end
