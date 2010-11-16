class PluginImagesController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 


  def create
    if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions                 
      
      acceptable_file_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
      uploaded_file = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url])
      filename = File.basename(uploaded_file.path)
      if Uploader.check_file_extension(:filename => filename, :extensions => acceptable_file_extensions)
       image = Magick::Image.from_blob(File.open(uploaded_file.path).read)[0] # read in image binary, from_blob returns an array of images, grab first item
              
        @image = PluginImage.new(params[:image])
        @image.description = params[:description]
        @image.url = "/images/item_images/#{@item.id}/normal/#{filename}"
        @image.thumb_url = "/images/item_images/#{@item.id}/thumbnails/#{filename}"
        @image.item_id = @item.id
        @image.user_id = @logged_in_user.id
        
        # generate image, apply special effects, save image to filesystem 
        Uploader.generate_image(
          :image => image,
          :path => RAILS_ROOT + "/public" + @image.url,          
          :thumbnail_path => RAILS_ROOT + "/public" + @image.thumb_url,
          :effects => params[:effects],
          :resize_image => @plugin.get_setting_bool("resize_item_images"),
          :resized_image_width => @plugin.get_setting("item_image_width").to_i,
          :resized_image_height => @plugin.get_setting("item_image_height").to_i,
          :thumbnail_width => @plugin.get_setting("item_thumbnail_width").to_i,
          :thumbnail_height => @plugin.get_setting("item_thumbnail_height").to_i
        ) 
        
        # Set Approval
        @image.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin
 
        if @image.save # if image was saved successfully
          Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.human_name, :name => @image.filename))                 
          flash[:success] =  t("notice.item_create_success", :item => @plugin.human_name)
          flash[:success] +=  t("notice.item_needs_approval", :item => @plugin.human_name) if !@image.is_approved?      
        else # save failed
          flash[:failure] =  t("notice.item_create_failure", :item => @plugin.human_name)
        end
      else
        flash[:failure] = t("notice.invalid_file_extensions", :item => @plugin.human_name, :acceptable_file_extensions => acceptable_file_extensions)      
      end      
    else # Improper Permissions  
      flash[:failure] = t("notice.invalid_permissions")           
    end   
    
    if params[:tinymce] == "true" # redirect them back to the tinymce popup box
      redirect_to :action => "tinymce_images", :controller => "pages", :item_id => @item.id     
    else # redirect them back to item page
      redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.human_name.pluralize     
    end
  end 

  def delete
    if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           
       @image = PluginImage.find(params[:image_id])
       if @image.destroy
         Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.human_name, :name => @image.filename))                        
         flash[:success] =  t("notice.item_delete_success", :item => @plugin.human_name)     
       else # fail saved 
         flash[:failure] =  t("notice.item_delete_failure", :item => @plugin.human_name)   
       end
     else # Improper Permissions  
          flash[:failure] = t("notice.invalid_permissions")            
     end  
     
    if params[:tinymce] == "true" # redirect them back to the tinymce popup box
      redirect_to :action => "tinymce_images", :controller => "pages", :item_id => @item.id     
    else # redirect them back to item page
      redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.human_name.pluralize     
    end
  end

  def change_main_image
    @old_main_image = PluginImage.find(:first, :order => "created_at ASC")
    @new_main_image = PluginImage.find(params[:image_id])
    
    swap_time = @old_main_image.created_at 
    
    # Swap creation times, which determines the main image
    @old_main_image.update_attribute(:created_at, @new_main_image.created_at)
    @new_main_image.update_attribute(:created_at, swap_time)
    
    flash[:success] =  t("notice.save_sucess") 
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_approve", :item => @plugin.human_name, :name => @file.filename))
    redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.human_name.pluralize 
  end

 
 def change_approval
    @image = PluginImage.find(params[:image_id])    
    if  @image.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.human_name, :name => @image.filename) 
    else
      approval = "1" # set to approved if unapproved already    
      log_msg =  t("log.item_approve", :item => @plugin.human_name, :name => @image.filename) 
    end
    
    if @image.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_approve_success", :item => @plugin.human_name) 
    else
      flash[:failure] =  t("notice.item_save_failure", :item => @plugin.human_name)
    end
    redirect_to :action => "view", :controller => "items", :id => @item, :anchor => @plugin.human_name.pluralize 
  end  

  def tiny_mce_images # display images in tinymce  
  end
  
  def filename
    return File.basename(self.url)
  end
  

  
private  
end
