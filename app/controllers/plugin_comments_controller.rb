class PluginCommentsController < PluginController 
 before_filter :can_group_create_plugin, :only => [:create, :reply]
 include ActionView::Helpers::TextHelper # for truncate, etc.
 
 def create # this is the only create action that doesn't require that the item is editable by the user
   if simple_captcha_valid? || !@logged_in_user.anonymous?
     @item = Item.find(params[:id])
     @plugin_comment = PluginComment.new(params[:plugin_comment])
     if !@logged_in_user.anonymous? # if the user is not anonymous
       @plugin_comment.user_id = @logged_in_user.id # set comment user id
     else # a visitor is leaving the comment.
     end 
     
     # Set Approval
     @plugin_comment.is_approved = "1" if !@group_permissions_for_plugin.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
     
     @plugin_comment.item_id = @item.id
     if @plugin_comment.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => truncate(@plugin_comment.comment, :length => 10)))  if !@logged_in_user.anonymous?
      Log.create(:item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => "#{request.env["REMOTE_ADDR"]}: " + truncate(@plugin_comment.comment, :length => 10))) if @logged_in_user.anonymous?
      
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@plugin_comment.is_approved?
     else # fail saved 
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
     end
   else # captcha failed'
     flash[:failure] = t("notice.invalid_captcha") 
   end
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.model_name.human(:count => :other) 
 end 
 
 def delete
   @plugin_comment = PluginComment.find(params[:comment_id])
   if @plugin_comment.destroy
     Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human, :name => truncate(@plugin_comment.comment, :length => 10)) ) 
     flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)     
   else # fail saved 
     flash[:failure] = t("notice.item_delete_failure", :item => @plugin.model_name.human)        
   end      
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.model_name.human(:count => :other) 
 end
 
 def new
   @plugin_comment = PluginComment.new
   @plugin_comment.parent_id = PluginComment.find(params[:parent_id]) if !params[:parent_id].blank?
    respond_to do |format|
      format.html{ 
         render :layout => false if request.xhr?
      }
    end
 end
 
 def edit
   @plugin_comment = PluginComment.find(params[:comment_id]) 
 end
 
 def update
   @plugin_comment = PluginComment.find(params[:comment_id])
   if @plugin_comment.update_attributes(params[:plugin_comment])
     Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_update", :item => @plugin.model_name.human, :name => truncate(@plugin_comment.comment, :length => 10)) ) 
     flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)     
   else # fail saved 
     flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)        
   end      
   redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.model_name.human(:count => :other)   
 end
end
