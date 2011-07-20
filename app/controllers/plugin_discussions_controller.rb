class PluginDiscussionsController < PluginController
 before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout. 
 before_filter :can_group_read_plugin, :only => [:view, :create_post, :rss]
 before_filter :can_group_update_plugin, :only => [:delete_post] 
 before_filter :get_all_group_plugin_permissions, :only => [:view]

 include ActionView::Helpers::TextHelper # for truncate, etc.

 def create # this is the only create action that doesn't require that the item is editable by the user
   @discussion = PluginDiscussion.new(params[:discussion])

   # Set Approval
   @discussion.is_approved = "1" if !@group_permissions_for_plugin.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
   @discussion.user_id = @logged_in_user.id
   @discussion.item_id = @item.id
   if @discussion.save
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => "#{@discussion.title}"))            
    flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:success] += " " + t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@discussion.is_approved?
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
   end 
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.model_name.human(:count => :other) 
 end 
 
 def delete
   @discussion = PluginDiscussion.find(params[:discussion_id])
   if @discussion.destroy
     Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human, :name => "#{@discussion.title}")) 
     flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)   
   else # fail saved 
     flash[:failure] = t("notice.item_failure_success", :item => @plugin.model_name.human)    
   end      
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.model_name.human(:count => :other) 
 end
 
 def view
   @discussion = PluginDiscussion.find(params[:discussion_id])
   @posts = PluginDiscussionPost.paginate :page => params[:page], :per_page => 10, :conditions => ["plugin_discussion_id = ?", @discussion.id], :order => "created_at ASC"
   @setting[:show_item_nav_links] = true # show nav links       
 end
 
 def create_post
   @discussion = PluginDiscussion.find(params[:discussion_id])
   @post = PluginDiscussionPost.new(params[:post])
   @post.user_id = @logged_in_user.id
   @post.plugin_discussion_id = @discussion.id
   @post.item_id = @item.id 
   
   if @post.save
     Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => PluginDiscussionPost.model_name.human,  :name =>  "#{@post.plugin_discussion.title} - " + truncate(@post.post, :length => 10)))                   
     flash[:success] = t("notice.item_create_success", :item => PluginDiscussionPost.model_name.human) 
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => PluginDiscussionPost.model_name.human)      
   end
   redirect_to :action => "view", :controller => "plugin_discussions", :id => @item, :discussion_id => @discussion.id, :anchor => @post.id       
 end
 
 def delete_post   
    @post = PluginDiscussionPost.find(params[:post_id])
    @discussion = @post.plugin_discussion
    if @post.destroy
       Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => PluginDiscussionPost.model_name.human, :name => "#{@post.plugin_discussion.title} - " + truncate(@post.post,:length =>  10)))                      
       flash[:success] = t("notice.item_delete_success", :item => PluginDiscussionPost.model_name.human) 
    else # delete failed 
      flash[:failure] = t("notice.item_delete_failure", :item => PluginDiscussionPost.model_name.human)      
    end
    redirect_to :action => "view", :controller => "plugin_discussions", :id => @item, :discussion_id => @discussion.id 
 end
 

 def rss
   @discussion = PluginDiscussion.find(params[:discussion_id])
   if @item.is_viewable_for_user?(@logged_in_user) # make sure user can see the item   
     @posts = PluginDiscussionPost.find(:all, :conditions => ["plugin_discussion_id = ?", @discussion.id], :limit => 30) 
     render :layout => false
   else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
     flash[:failure] = t("notice.not_visible")             
     redirect_to :action => "index", :category => "browse"
   end    
 end   
end
