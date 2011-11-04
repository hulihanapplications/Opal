class PluginVideosController < PluginController
  before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.

  def create
   @video = PluginVideo.new(params[:plugin_video])
   @video.user_id = @logged_in_user.id
   @video.record = @item
            
   if @video.save
    log(:log_type => "create", :target => @video)
    flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
    flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@video.is_approved?
    redirect_to record_path(@video.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
   else # fail saved 
    flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
    render :action => "new"
   end  
  end
 
  def update
   @video = @record
   @video.attributes = params[:plugin_video]
   if @video.save
    log(:log_type => "update", :target => @video)
    flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
    redirect_to :back
   else # fail saved 
     flash[:success] = t("notice.item_save_failure", :item => @plugin.model_name.human)
     render :action => "edit"
   end    
  end
  
  def delete
    @video = @record
    if @video.destroy
      log(:log_type => "destroy", :target => @item)
      flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
    else # fail saved
      flash[:success] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
    end

    redirect_to :back
  end  
 
  def new 
    @video = PluginVideo.new    
  end
 
  def edit
    @video = @record
  end
  
  def show
  	@video = @record
    respond_to do |format|
      format.html{render :layout => false if request.xhr?}
      format.js{render :layout => false }
    end    	 
  end
end
