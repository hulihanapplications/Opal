class PluginDiscussionsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 include ActionView::Helpers::TextHelper # for truncate, etc.
 uses_tiny_mce :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.



 def create # this is the only create action that doesn't require that the item is editable by the user
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @discussion = PluginDiscussion.new(params[:discussion])

     # Set Approval
     @discussion.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
           
     @discussion.item_id = @item.id
     if @discussion.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.human_name, :name => "#{@disccussion.title}"))            
      flash[:success] = t("notice.item_create_success", :item => @plugin.human_name)
      flash[:success] += t("notice.item_needs_approval", :item => @plugin.human_name) if !@discussion.is_approved?
     else # fail saved 
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")            
   end  
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.human_name.pluralize 
 end 
 
 def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @discussion = PluginDiscussion.find(params[:discussion_id])
     if @discussion.destroy
       Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.human_name, :name => "#{@disccussion.title}")) 
       flash[:success] = t("notice.item_delete_success", :item => @plugin.human_name)   
     else # fail saved 
       flash[:failure] = t("notice.item_failure_success", :item => @plugin.human_name)    
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")       
   end       
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.human_name.pluralize 
 end
 
 def view
   if @item.is_viewable_for_user?(@logged_in_user)
     if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?

       @discussion = PluginDiscussion.find(params[:discussion_id])
       @posts = PluginDiscussionPost.paginate :page => params[:page], :per_page => 10, :conditions => ["plugin_discussion_id = ?", @discussion.id], :order => "created_at ASC"
       @setting[:show_item_nav_links] = true # show nav links
     else # Improper Permissions  
          flash[:failure] = t("notice.invalid_permissions")       
     end        
   else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
     flash[:failure] = t("notice.not_visible")   
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
         Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => PluginDiscussionPost.human_name,  :name =>  "#{@post.plugin_discussion.title} - " + truncate(@post.post, :length => 10)))                   
         flash[:success] = t("notice.item_create_success", :item => PluginDiscussionPost.human_name) 
       else # fail saved 
        flash[:failure] = t("notice.item_create_failure", :item => PluginDiscussionPost.human_name)      
       end
       redirect_to :action => "view", :controller => "plugin_discussions", :id => @item, :discussion_id => @discussion.id, :anchor => @post.id
     else # Improper Permissions  
          flash[:failure] = t("notice.invalid_permissions")         
     end         
   else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
     flash[:failure] = t("notice.not_visible")   
     redirect_to :action => "index", :category => "browse"     
   end 
 end
 
 def delete_post   
  if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
    @post = PluginDiscussionPost.find(params[:post_id])
    @discussion = @post.plugin_discussion
    if @post.destroy
       Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => PluginDiscussionPost.human_name, :name => "#{@post.plugin_discussion.title} - " + truncate(@post.post,:length =>  10)))                      
       flash[:success] = t("notice.item_delete_success", :item => PluginDiscussionPost.human_name) 
    else # delete failed 
      flash[:failure] = t("notice.item_delete_failure", :item => PluginDiscussionPost.human_name)      
    end
     redirect_to :action => "view", :controller => "plugin_discussions", :id => @item, :discussion_id => @discussion.id
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")         
   end    
 end
 

 def rss
   if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?   
     @discussion = PluginDiscussion.find(params[:discussion_id])
     if @item.is_viewable_for_user?(@logged_in_user) # make sure user can see the item   
       @posts = PluginDiscussionPost.find(:all, :conditions => ["plugin_discussion_id = ?", @discussion.id], :limit => 30) 
       render :layout => false
     else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
       flash[:failure] = t("notice.invalid_permissions")    
       redirect_to :action => "index", :category => "browse"
     end  
   else # Improper Permissions  
        flash[:failure] = t("notice.not_visible")        
   end   
 end   

 def change_approval
    @discussion = PluginDiscussion.find(params[:discussion_id])    
    if  @discussion.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.human_name, :name => @discussion.title)  
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @plugin.human_name, :name => @discussion.title) 
    end
    
    if @discussion.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_approve_success", :item => @plugin.human_name) 
    else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.human_name) 
    end
    redirect_to :action => "view", :controller => "items", :id => @item
  end

end
