class PluginLinksController < PluginController
  def create
    @link = PluginLink.new
    @link.title = params[:link_title]
    @link.url = params[:link_url]
    @link.user_id = @logged_in_user.id
    @link.record = @item

    if @link.save
      log(:log_type => "create", :target => @link)
      flash[:success] =  t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:notice] +=  t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@link.is_approved?
    else # fail saved
      flash[:failure] =  t("notice.item_create_failure", :item => @plugin.model_name.human)
    end
 
    redirect_to record_path(@link.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
  end
 
  def update
    @link = @record
    if @link.update_attribute(:title, params[:link_title]) && @link.update_attribute(:url, params[:link_url])
      log(:log_type => "update", :target => @link)
      flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
    else # fail saved
      flash[:failure] =  t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
  
    redirect_to :back
  end
  
  def delete
    @link = @record
    if @link.destroy
      log(:log_type => "destroy", :target => @link)
      flash[:success] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)
    else # fail saved 
      flash[:failure] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)
    end
 
    redirect_to :back
  end  
end
