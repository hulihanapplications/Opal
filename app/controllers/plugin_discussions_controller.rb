class PluginDiscussionsController < PluginController
 before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout. 
 before_filter(:only => [:view, :create_post, :rss]) {|c|  can?(@record, @logged_in_user, :view)} 
 before_filter(:only => [:delete_post]) {|c|  can?(@record, @logged_in_user, :destroy)} 

 include ActionView::Helpers::TextHelper # for truncate, etc.

 def create # this is the only create action that doesn't require that the item is editable by the user
   @discussion = PluginDiscussion.new(params[:discussion])
   @discussion.user_id = @logged_in_user.id
   @discussion.record = @item
   if @discussion.save
    log(:log_type => "create", :target => @discussion)
    flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:success] += " " + t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@discussion.is_approved?
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
   end 
   redirect_to record_path(@discussion.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
 end 
 
 def delete
   @discussion = @record
   if @discussion.destroy
     log(:log_type => "destroy", :target => @discussion)
     flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)   
   else # fail saved 
     flash[:failure] = t("notice.item_failure_success", :item => @plugin.model_name.human)    
   end      
   redirect_to :back 
 end
 
 def view
   @discussion = @record
   @posts = PluginDiscussionPost.paginate :page => params[:page], :per_page => 10, :conditions => ["plugin_discussion_id = ?", @discussion.id], :order => "created_at ASC"
   @setting[:show_item_nav_links] = true # show nav links       
 end
 
 def create_post
   @discussion = @record
   @post = PluginDiscussionPost.new(params[:post])
   @post.user_id = @logged_in_user.id
   @post.plugin_discussion_id = @discussion.id
   
   if @post.save
     log(:log_type => "create", :target => @post)
     flash[:success] = t("notice.item_create_success", :item => PluginDiscussionPost.model_name.human) 
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => PluginDiscussionPost.model_name.human)      
   end
   redirect_to :back
 end
 
 def delete_post   
    @post = PluginDiscussionPost.find(params[:post_id])
    @discussion = @post.plugin_discussion
    if @post.destroy
       log(:log_type => "destroy", :target => @post)
       flash[:success] = t("notice.item_delete_success", :item => PluginDiscussionPost.model_name.human) 
    else # delete failed 
      flash[:failure] = t("notice.item_delete_failure", :item => PluginDiscussionPost.model_name.human)      
    end
    redirect_to :back
 end


 def rss
   @discussion = @record
   @posts = PluginDiscussionPost.find(:all, :conditions => ["plugin_discussion_id = ?", @discussion.id], :limit => 30) 
   render :layout => false  
 end   
end
