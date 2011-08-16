class PluginVideosController < PluginController
  before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.

  def create
   @video = PluginVideo.new(params[:video])
   @video.user_id = @logged_in_user.id
   @video.item_id = @item.id
   
   # Set Approval
   @video.is_approved = "1" if !@group_permissions_for_plugin.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
         
   if @video.save
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "create", :log => t("log.item_create", :item => @plugin.model_name.human, :name => @video.title))             
    flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@video.is_approved?
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other)     
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
    render :action => "new"
   end  
  end
 
  def update
   @video = PluginVideo.find(params[:video_id])
   @video.attributes = params[:video]
   if @video.save
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_save", :item => @plugin.model_name.human, :name => @video.title))                    
    flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
    redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.model_name.human(:count => :other) 
   else # fail saved 
     flash[:success] = t("notice.item_save_failure", :item => @plugin.model_name.human)
     render :action => "edit"
   end    
  end
  
  def delete
   @video = PluginVideo.find(params[:video_id])
   if @video.destroy
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human, :name => @video.title))                           
    flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
   else # fail saved 
     flash[:success] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
   end
  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
 end  
 
  def new 
    @video = PluginVideo.new    
  end
 
  def edit
    @video = PluginVideo.find(params[:video_id])   
  end
  
  def show
  	@video = PluginVideo.find(params[:video_id])  
    respond_to do |format|
      format.html do
      	render :layout => false if request.xhr?
      end    
    end    	 
  end
end
