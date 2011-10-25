class PluginDescriptionsController < PluginController
 before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.
 include ActionView::Helpers::TextHelper # for truncate, sanitize, etc.

  def create
   @description = PluginDescription.new(params[:description])
   @description.user_id = @logged_in_user.id
   @description.record = @item
            
   if @description.save
    log(:log_type => "create", :target => @description)
    flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@description.is_approved?
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
   end  
   redirect_to record_path(@description.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
  end
 
  def update
   @description = @record
   @description.attributes = params[:description]   
   if @description.save
    log(:log_type => "update", :target => @description)
    flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
   else # fail saved 
     flash[:success] = t("notice.item_save_failure", :item => @plugin.model_name.human)
   end    
   redirect_to :back, :anchor => @plugin.model_name.human(:count => :other) 
  end
  
  def delete
   @description = @record
   if @description.destroy
    log(:log_type => "destroy", :target => @description)
    flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
   else # fail saved 
     flash[:success] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
   end
  
   redirect_to :back, :anchor => @plugin.model_name.human(:count => :other) 
  end  
 
  def new 
    @description = PluginDescription.new    
  end
 
  def edit
    @description = @record
  end
end
