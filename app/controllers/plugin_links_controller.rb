class PluginLinksController < PluginController
  def create
   @link = PluginLink.new
   @link.title = params[:link_title]
   @link.url = params[:link_url]
   @link.user_id = @logged_in_user.id
   @link.item_id = @item.id
 
   # Set Approval
   @link.is_approved = "1" if !@group_permissions_for_plugin.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
      
   if @link.save
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => @link.title))                        
    flash[:success] =  t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:notice] +=  t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@link.is_approved?       
   else # fail saved 
    flash[:failure] =  t("notice.item_create_failure", :item => @plugin.model_name.human)
   end
 
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
 
  def update
   @link = PluginLink.find(params[:link_id])
   if @link.update_attribute(:title, params[:link_title]) && @link.update_attribute(:url, params[:link_url])
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log =>  t("log.item_save", :item => @plugin.model_name.human, :name => @link.title))                               
    flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
   else # fail saved 
     flash[:failure] =  t("notice.item_save_failure", :item => @plugin.model_name.human)
   end
  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
  
  def delete
    @link = PluginLink.find(params[:link_id])
    if @link.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log =>  t("log.item_delete", :item => @plugin.model_name.human, :name => @link.title))                                      
      flash[:success] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)
    else # fail saved 
      flash[:failure] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)
    end
 
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end  
end
