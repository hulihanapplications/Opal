class PluginCommentsController < PluginController 
 before_filter(:only => [:create, :reply]) {|c|  can?(PluginComment, @logged_in_user, :create)} 
 include ActionView::Helpers::TextHelper # for truncate, etc.
 
 def create # this is the only create action that doesn't require that the item is editable by the user
   if human? || !@logged_in_user.anonymous?
     @plugin_comment = PluginComment.new(params[:plugin_comment])
     @plugin_comment.user = @logged_in_user   # set comment user id
     
     @plugin_comment.record = @record if defined?(@record)
     if @plugin_comment.save
      log(:log_type => "create", :target => @plugin_comment)

      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@plugin_comment.is_approved?
     else # fail saved 
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
     end
   else # humanizer failure
     flash[:failure] = I18n.translate("humanizer.validation.error")
   end
   redirect_to :back, :anchor => @plugin.model_name.human(:count => :other) 
   # record_path(@plugin_comment.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
 end 
 
 def delete
   @plugin_comment = @record
   if @plugin_comment.destroy
     log(:log_type => "destroy", :target => @plugin_comment)
     flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)     
   else # fail saved 
     flash[:failure] = t("notice.item_delete_failure", :item => @plugin.model_name.human)        
   end      
   redirect_to :back, :anchor => @plugin.model_name.human(:count => :other) 
 end
 
 def new
   @plugin_comment = PluginComment.new
   @plugin_comment.parent_id = PluginComment.find(params[:parent_id]) if !params[:parent_id].blank?
   respond_to do |format|
     format.html{render :layout => false if request.xhr?}
   end
 end
 
 def edit
   @plugin_comment = @record
 end
 
 def update
   @plugin_comment = @record
   if @plugin_comment.update_attributes(params[:plugin_comment])
     log(:log_type => "update", :target => @plugin_comment)
     flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)     
   else # fail saved 
     flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)        
   end      
   redirect_to :back, :anchor => @plugin.model_name.human(:count => :other) 
 end
end
