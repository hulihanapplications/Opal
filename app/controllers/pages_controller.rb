class PagesController < ApplicationController
 before_filter :authenticate_admin, :except => [:create_page_comment, :redirect_to_page, :page, :tinymce_images] # make sure logged in user is an admin    
 before_filter :enable_admin_menu # show admin menu 
 
 uses_tiny_mce :only => [:new, :edit]  # which actions to load tiny_mce, TinyMCE Config is done in Layout. 
 
 def index
   @setting[:meta_title] = "Pages - Admin - "+ @setting[:meta_title]
   params[:type] ||= "System" # set default
   if params[:type] == "Blog" # if blog pages
     order = "created_at DESC" # set order
   else # all other page types
     order = "title ASC"         
   end
   @pages = Page.paginate  :page => params[:page], :per_page => 25, :conditions => ["page_type = ? and page_id = 0", params[:type].downcase], :order => order
 end
  
 def create
    params[:page][:content] = params[:page][:content] # clean user input   
    @page = Page.new(params[:page])
    @page.user_id = @logged_in_user.id
    if @page.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => "Created the #{@page.title} page.")             
      flash[:notice] = "<div class=\"flash_success\">Page was successfully created.</div>"
    else
        flash[:notice] = "<div class=\"flash_failure\">Page could not be created!  Here's why:<br>#{print_errors(@page)}</div>"
    end
    redirect_to :action => 'index', :type => @page.page_type.capitalize   
 end
 
 def update
   @page = Page.find(params[:id])
   if params[:page][:page_id].to_i != @page.id # trying to select self as parent category    
     params[:page][:content] = params[:page][:content] # clean user input      
      if @page.update_attributes(params[:page]) 
        flash[:notice] = "<div class=\"flash_success\">Page was successfully updated.</div>"
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Updated the #{@page.title} page(#{@page.id}).")                   
      else
        flash[:notice] = "<div class=\"flash_failure\">Page could not be updated!  Here's why:<br>#{print_errors(@page)}</div>"
      end
    else
      flash[:notice] = "<div class=\"flash_failure\">A page can't be a subpage of itself!</div>"
    end 
    redirect_to :action => 'edit', :id => @page.id, :type => @page.page_type.capitalize  
 end
 
 def delete
   @page = Page.find(params[:id])   
   if @page.is_system_page? # Can't delete system pages
     flash[:notice] = "<div class=\"flash_failure\">Sorry, You can't delete system pages.</div>"
   else 
     Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Deleted the #{@page.title} page(#{@page.id}).")                        
     flash[:notice] = "<div class=\"flash_success\">Page deleted!</div>"
     @page.destroy
   end
   redirect_to :action => 'index', :type => @page.page_type.capitalize     
 end  
 
 def create_page_comment # this is the only create action that doesn't require that the item is editable by the user
   @page = Page.find(params[:id])
   if simple_captcha_valid?
     if !@page.is_system_page? # only public pages can have comments
       if (@logged_in_user.id != 0  && Setting.get_setting_bool("allow_page_comments")) || @logged_in_user.is_admin? # make sure the user is logged in and can leave page comments 
             @comment = PageComment.new(params[:comment])
             @comment.page_id = @page.id
             @comment.is_approved = "1" # force approval
             if @logged_in_user.id != 0 # if the user is not anonymous
               @comment.user_id = @logged_in_user.id # set comment user id
             end 
             if @comment.save
              Log.create(:user_id => @logged_in_user.id,  :log_type => "new", :log => "Left a comment on the #{@page.title} page.") if @logged_in_user.id != 0
              Log.create(:item_id => @item.id,  :log_type => "new", :log => "A visitor at #{request.env["REMOTE_ADDR"]} left a comment on the #{@page.title} page.") if @logged_in_user.id == 0
              
              flash[:notice] = "<div class=\"flash_success\">New Comment added. Thanks for your input!</div><br>"
             else # fail saved 
              flash[:notice] = "<div class=\"flash_failure\">This Comment could not be added! Here's why:<br>#{print_errors(@comment)}<</div>>"
             end 
       else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
            flash[:notice] = "<div class=\"flash_failure\">Sorry, you're not allowed to leave a comment.</div>"        
       end
     else # they are trying to leave a comment on a non-public page
       flash[:notice] = "<div class=\"flash_failure\">Sorry, system pages can't have comments.</div>"        
     end 
   else # captcha failed'
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you entered in the wrong Anti-Spam code.</div>"
   end
   
   redirect_to :action => "page", :id => @page.id # go to page
 end 

 def delete_page_comment
   @page_comment = PageComment.find(params[:id])   
   Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Delete comment from the #{@page_comment.page.title} page.")                        
   flash[:notice] = "<div class=\"flash_success\">Comment deleted!</div>"
   @page_comment.destroy
   redirect_to :action => "page", :id => @page_comment.page_id # go to page
 end  

  def new
    @page = Page.new
    params[:type] ||= "Public"
    @page.page_type = params[:type].downcase
    if params[:id]
      @page.page_id = params[:id].to_i
    end
  end
  
  def edit
    @page = Page.find(params[:id])
    @page_comments = PageComment.paginate :page => params[:page], :per_page => 25, :conditions => ["page_id = ? and is_approved = ?", @page.id, "1"]
    params[:type] = @page.page_type.capitalize
  end
  
  def page # go to page
    page = Page.find(params[:id])
    if page.published || @logged_in_user.is_admin? # make sure this is a published page they're going to
      if page.page_type == "blog" # go to blog page
        redirect_to :action => "page", :controller => "blog", :id => page
      else # public page 
        redirect_to :action => "page", :controller => "about", :id => page     
      end
    else
      flash[:notice] = "<div class=\"flash_failure\">Sorry, you're not allowed to see this.</div>"      
      redirect_to :action => "index", :controller => "browse"
    end 
  end
  
  def tinymce_images # show images to use with tinymce images
    @plugin = Plugin.find_by_name("Image") # use Images Plugin for titles and thumbnail settings      
    if params[:item_id] # get images for item
      @item = Item.find(params[:item_id])
      check_item_edit_permissions
      @images = PluginImage.find(:all, :conditions => ["item_id = ?", @item.id])
    else # get images for system
      authenticate_admin # make sure they're an admin
      @images = Image.find(:all)
    end 
    render :layout => false 
  end

  def upload_image  
      @plugin = Plugin.find_by_name("Image") # use Images Plugin for title and thumbnail settings
      acceptable_file_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
      uploaded_file = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url])
      filename = File.basename(uploaded_file.path)
      if Uploader.check_file_extension(:filename => filename, :extensions => acceptable_file_extensions)
       image = Magick::Image.from_blob(File.open(uploaded_file.path).read)[0] # read in image binary, from_blob returns an array of images, grab first item
              
        @image = Image.new(params[:image])
        @image.description = params[:description]
        if @image.save # save to obtain next id assigned by db
          @image.url = "/images/uploaded_images/#{@image.id}/normal/#{filename}"
          @image.thumb_url = "/images/uploaded_images/#{@image.id}/thumbnails/#{filename}"
          @image.user_id = @logged_in_user.id
          
          if @image.save # if image was saved successfully
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
          
            Log.create(:user_id => @logged_in_user.id,  :log_type => "new", :log => "Added #{@plugin.title}: #{filename}.")                 
            flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} added successfully!</div>"
          else 
            flash[:notice] = "<div class=\"flash_failure\">Your #{@plugin.title} couldn't be saved!<br>Here's why:<br>#{print_errors(@image)}</div>"            
          end 
        else # save failed
          flash[:notice] = "<div class=\"flash_failure\">Your #{@plugin.title} could not obtain an ID from the database!<br>Here's why:<br>#{print_errors(@image)}</div>"
        end
      else
        flash[:notice] = "<div class=\"flash_failure\">#{params[:file].original_filename} upload failed! Please make sure that this is an image file, and that it ends in #{acceptable_file_extensions}</div> "     
    end
    redirect_to :action => "tinymce_images"
  end

  def delete_image
     @image = Image.find(params[:id])
      @plugin = Plugin.find_by_name("Image") # use Images Plugin for title and thumbnail settings     
     if @image.destroy
       Log.create(:user_id => @logged_in_user.id,  :log_type => "delete", :log => "Deleted #{@plugin.title}: #{File.basename(@image.url)}.")                        
       flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} deleted!</div>"     
     else # fail saved 
       flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} could not be deleted!</div>"     
     end
    redirect_to :action => "tinymce_images"
  end  
  
end
