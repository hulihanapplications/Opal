class PluginImagesController < PluginController
  def single_access_allowed?
    action_name == "create" 
  end  
  
  def new
    @image = PluginImage.new
  end

  def create
    @image = PluginImage.new(params[:plugin_image])
    @image.user = @logged_in_user
    @image.record = @record if defined?(@record)     
    @image.effects = params[:plugin_image][:effects]
    @image.image = params[:plugin_image][:image] 
    @image.remote_image_url = params[:plugin_image][:remote_image_url] 
    
    if @image.save # if image was saved successfully
      flash[:success] =  t("notice.item_create_success", :item => PluginImage.model_name.human)
      flash[:success] +=  t("notice.item_needs_approval", :item => PluginImage.model_name.human) if !@image.is_approved?
      log(:log_type => "create", :target => @image)
      
      respond_to do |format|
        format.html{
          if params[:tinymce] == "true" # redirect them back to the tinymce popup box
            redirect_to :back      
          else # redirect them back to item page
            redirect_to record_path(@image.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
          end       
        }
        format.flash{ render :text => t("notice.item_create_success", :item => PluginImage.model_name.human + (!@image.filename.blank? ? ": #{@image.filename}" : "") ) }              
      end           
    else # save failed
      flash[:failure] =  t("notice.item_create_failure", :item => PluginImage.model_name.human)
      respond_to do |format|
        format.html{render :action => "new"}   
        format.flash{render :text =>  t("notice.item_create_failure", :item => PluginImage.model_name.human + (!@image.filename.blank? ? ": #{@image.filename}" : "") ) + "\n" + @image.errors.full_messages.join("\n")}
      end
    end    
  end 

  def delete
    @image = @record
    if @image.destroy
      log(:log_type => "destroy", :target => @image)
      flash[:success] =  t("notice.item_delete_success", :item => PluginImage.model_name.human)     
    else # fail saved 
      flash[:failure] =  t("notice.item_delete_failure", :item => PluginImage.model_name.human)   
    end
    
    if params[:tinymce] == "true" # redirect them back to the tinymce popup box
      redirect_to :back, :anchor => @plugin.model_name.human(:count => :other) 
    else # redirect them back to item page
      redirect_to :back, :anchor => @plugin.model_name.human(:count => :other) 
    end
  end

  def edit
    @image = @record   
  end
  
  def update
    @image = @record
    if @image.update_attributes(params[:plugin_image])
       log(:log_type => "update", :target => @image)
       flash[:success] =  t("notice.item_save_success", :item => PluginImage.model_name.human)     
    else
      flash[:success] =  t("notice.item_save_failure", :item => PluginImage.model_name.human)     
    end 
    render :action => "edit"
  end

  def tinymce # show images to use with tinymce images
    @plugin_image = PluginImage.new
    if @record.is_a?(Item)
      @images = PluginImage.record(@record).paginate(:page => params[:page], :per_page => 25)
    else
      authenticate_admin
      @images = PluginImage.paginate(:page => params[:page], :per_page => 25)      
    end 
    render :layout => false 
  end
  
private  
end
