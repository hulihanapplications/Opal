class PluginDescriptionsController < PluginController
 before_filter :can_group_create_plugin, :only => [:new, :create]
 before_filter :can_group_update_plugin, :only => [:edit, :update] 
 before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.
 include ActionView::Helpers::TextHelper # for truncate, sanitize, etc.

  def create
   @description = PluginDescription.new(params[:description])
   @description.user_id = @logged_in_user.id
   @description.item_id = @item.id
   
   # Set Approval
   @description.is_approved = "1" if !@group_permissions_for_plugin.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
         
   if @description.save
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "create", :log => t("log.item_create", :item => @plugin.model_name.human, :name => @description.title))             
    flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@description.is_approved?
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
 
  def update
   @description = PluginDescription.find(params[:description_id])
   @description.attributes = params[:description]   
   if @description.save
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_save", :item => @plugin.model_name.human, :name => @description.title))                    
    flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
   else # fail saved 
     flash[:success] = t("notice.item_save_failure", :item => @plugin.model_name.human)
   end    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
  
  def delete
   @description = PluginDescription.find(params[:description_id])
   if @description.destroy
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human, :name => @description.title))                           
    flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
   else # fail saved 
     flash[:success] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
   end
  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
 end  

 def change_approval
    @description = PluginDescription.find(params[:description_id])    
    if  @description.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.model_name.human, :name => truncate(@description.content, :length => 20))
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @plugin.model_name.human, :name => truncate(@description.content, :length => 20))
    end
    
    if @description.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @plugin.model_name.human)  
    else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
 
  def new 
    @description = PluginDescription.new    
  end
 
  def edit
    @description = PluginDescription.find(params[:description_id])   
  end
end
