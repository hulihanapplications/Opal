class PluginImagesController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Image"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
      flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div>"
      redirect_to :action => "view", :controller => "items", :id => @item.id        
   end
 end

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
          Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Added #{@plugin.title}: #{filename}.")                 
          flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} added successfully!</div>"
          flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !@image.is_approved?      
        else # save failed
          flash[:notice] = "<div class=\"flash_failure\">Your #{@plugin.title} couldn't be saved!<br>Here's why:<br>#{print_errors(@image)}</div>"
        end
      else
        flash[:notice] = "<div class=\"flash_failure\">#{params[:file].original_filename} upload failed! Please make sure that this is an image file, and that it ends in #{acceptable_file_extensions}</div> "     
      end      
    else # Improper Permissions  
      flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"        
    end   
    
    if params[:tinymce] == "true" # redirect them back to the tinymce popup box
      redirect_to :action => "tinymce_images", :controller => "pages", :item_id => @item.id     
    else # redirect them back to item page
      redirect_to :action => "view", :controller => "items", :id => @item, :anchor => "#{@plugin.name}s"     
    end
  end 

  def delete
    if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           
       @image = PluginImage.find(params[:image_id])
       if @image.destroy
         Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted #{@plugin.title}: #{File.basename(@image.url)}.")                        
         flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} deleted!</div>"     
       else # fail saved 
         flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} could not be deleted!</div>"     
       end
     else # Improper Permissions  
          flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div>"        
     end  
     
    if params[:tinymce] == "true" # redirect them back to the tinymce popup box
      redirect_to :action => "tinymce_images", :controller => "pages", :item_id => @item.id     
    else # redirect them back to item page
      redirect_to :action => "view", :controller => "items", :id => @item, :anchor => "#{@plugin.name}s"     
    end
  end

  def change_main_image
    @old_main_image = PluginImage.find(:first, :order => "created_at ASC")
    @new_main_image = PluginImage.find(params[:image_id])
    
    swap_time = @old_main_image.created_at 
    
    # Swap creation times, which determines the main image
    @old_main_image.update_attribute(:created_at, @new_main_image.created_at)
    @new_main_image.update_attribute(:created_at, swap_time)
    
    flash[:notice] = "<div class=\"flash_success\">Main #{@plugin.title} changed!</div>"  
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => "Changed main #{@plugin.title} to #{File.basename(@new_main_image.url)}.")
    redirect_to :action => "view", :controller => "items", :id => @item, :anchor => "#{@plugin.name}s" 
  end

 
 def change_approval
    @image = PluginImage.find(params[:image_id])    
    if  @image.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{File.basename(@image.url)}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{File.basename(@image.url)}."
    end
    
    if @image.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div>"
    end
    redirect_to :action => "view", :controller => "items", :id => @item, :anchor => "#{@plugin.name}s" 
  end  

  def tiny_mce_images # display images in tinymce  
  end
  
private  
end
