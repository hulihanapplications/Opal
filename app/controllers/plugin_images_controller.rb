class PluginImagesController < PluginController
  def new
    @image = PluginImage.new(:item_id => @item.id)
  end

  def create
    @image = PluginImage.new(params[:plugin_image])
    @image.effects = params[:effects]
    @image.user_id = @logged_in_user.id
    @image.item_id = @item.id
    @image.is_approved = "1" if !@group_permissions_for_plugin.requires_approval?  || @item.is_editable_for_user?(@logged_in_user) # approve if not required or owner or admin
    
    if @image.save # if image was saved successfully
      flash[:success] =  t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] +=  t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@image.is_approved?
      
      respond_to do |format|
        format.html{
          if params[:tinymce] == "true" # redirect them back to the tinymce popup box
            redirect_to :action => "tinymce_images", :controller => "pages", :item_id => @item.id     
          else # redirect them back to item page
            redirect_to :action => "view", :controller => "items", :id => @item
          end       
        }
        format.flash{ render :text => t("notice.item_create_success", :item => @plugin.model_name.human + (!@image.filename.blank? ? ": #{@image.filename}" : "") ) }              
      end           
    else # save failed
      flash[:failure] =  t("notice.item_create_failure", :item => @plugin.model_name.human)
      respond_to do |format|
        format.html{render :action => "new"}   
        format.flash{render :text =>  t("notice.item_create_failure", :item => @plugin.model_name.human + (!@image.filename.blank? ? ": #{@image.filename}" : "") ) + "\n" + @image.errors.full_messages.join("\n")}
      end
    end    
  end 


  def delete
    @image = PluginImage.find(params[:image_id])
    if @image.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human, :name => @image.filename))                        
      flash[:success] =  t("notice.item_delete_success", :item => @plugin.model_name.human)     
    else # fail saved 
      flash[:failure] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)   
    end
    
    if params[:tinymce] == "true" # redirect them back to the tinymce popup box
      redirect_to :action => "tinymce_images", :controller => "pages", :item_id => @item.id     
    else # redirect them back to item page
      redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.model_name.human(:count => :other)     
    end
  end

  def edit
     @image = PluginImage.find(params[:image_id])    
  end
  
  def update
    @image = PluginImage.find(params[:image_id])
    if @image.update_attributes(params[:plugin_image])
       flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)     
    else
      flash[:success] =  t("notice.item_save_failure", :item => @plugin.model_name.human)     
    end 
    render :action => "edit"
  end

  def tiny_mce_images # display images in tinymce  
  end
  
private  
end
