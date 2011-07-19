class PagesController < ApplicationController
 before_filter :authenticate_admin, :except => [:create_page_comment, :redirect_to_page, :page, :tinymce_images, :view, :send_contact_us] # make sure logged in user is an admin    
 before_filter :enable_admin_menu, :except => [:view, :send_contact_us]# show admin menu 
 before_filter :uses_tiny_mce, :only => [:new, :edit, :update, :destroy]  # which actions to load tiny_mce, TinyMCE Config is done in Layout. 
 
 def index
   @setting[:meta_title] << Page.model_name.human(:count => :other) 
   params[:type] ||= "public"
   if params[:type].downcase == "public"
      @pages = Page.all.root.public.in_order
   elsif params[:type].downcase == "blog"
      @pages = Page.all.root.blog.newest_first     
   elsif  params[:type].downcase == "system"
      @pages = Page.all.root.system.in_order     
   else # unknown page type   
      @pages = Page.all.root.public.in_order   
   end         
   @setting[:ui] = true
 end
  
 def create
    params[:page][:content] = params[:page][:content] # clean user input   
    @page = Page.new(params[:page])
    @page.user_id = @logged_in_user.id
    if @page.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("log.item_create", :item => Page.model_name.human, :name => @page.title))             
      flash[:success] = t("notice.item_create_success", :item => Page.model_name.human)
      redirect_to :action => 'index', :type => @page.page_type.capitalize   
    else
      flash[:failure] = t("notice.item_create_failure", :item => Page.model_name.human)
      params[:type] = @page.page_type.capitalize      
      render :action => "new"
    end
 end
 
 def update
   @page = Page.find(params[:id])
   if params[:page][:page_id].to_i != @page.id # trying to select self as parent category    
     params[:page][:content] = params[:page][:content] # clean user input      
      if @page.update_attributes(params[:page]) 
        flash[:success] = t("notice.item_save_success", :item => Page.model_name.human)
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => Page.model_name.human, :name => @page.title))
        redirect_to :action => 'edit', :id => @page.id, :type => @page.page_type.capitalize  
      else
        flash[:failure] = t("notice.item_save_failure", :item => Page.model_name.human)
        render :action => "edit"
      end
    else
      flash[:failure] = t("notice.association_loop_failure", :item => Page.model_name.human)
      render :action => "edit"
    end 
 end
 
 def delete
   @page = Page.find(params[:id])   
   if @page.is_system_page? # Can't delete system pages
     flash[:failure] = t("notice.invalid_permissions")
   else 
     Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => Page.model_name.human, :name => @page.title))                        
     flash[:success] = t("notice.item_delete_success", :item => Page.model_name.human)
     @page.destroy
   end
   redirect_to :action => 'index', :type => @page.page_type.capitalize     
 end  
 
 def create_page_comment # this is the only create action that doesn't require that the item is editable by the user
   @page = Page.find(params[:id])
   if simple_captcha_valid?
     if !@page.is_system_page? # only public pages can have comments
       if Setting.get_setting_bool("allow_page_comments") || @logged_in_user.is_admin? # make sure the user is logged in and can leave page comments 
             @comment = PageComment.new(params[:comment])
             @comment.page_id = @page.id
             @comment.is_approved = "1" # force approval
             @comment.user_id = @logged_in_user.id if !@logged_in_user.anonymous? # set comment user id 
             if @comment.save
              Log.create(:user_id => @logged_in_user.id,  :log_type => "new", :log => t("log.item_create", :item => PageComment.model_name.human, :name => @page.title)) if !@logged_in_user.anonymous?
              Log.create(:log_type => "new", :log => t("log.item_create", :item => PageComment.model_name.human, :name => @page.title + " (#{t("single.visior")}: #{request.env["REMOTE_ADDR"]})")) if @logged_in_user.anonymous?
              
              flash[:success] = t("notice.item_create_success", :item => PageComment.model_name.human)
             else # fail saved 
              flash[:failure] = t("notice.item_create_failure", :item => PageComment.model_name.human)
             end 
       else # Attempted Securtiy Bypass: User is trying to add a comment to an item that's not viewable. They shouldn't be able to get to the add comment form, but this stops them server-side.
            flash[:failure] = t("notice.invalid_permissions")        
       end
     else # they are trying to leave a comment on a non-public page
       flash[:failure] = t("notice.invalid_permissions")        
     end 
   else # captcha failed'
        flash[:failure] = t("notice.invalid_captcha")
   end
   redirect_to :back
   #redirect_to :action => "page", :id => @page.id # go to page
 end 

 def delete_page_comment
   @page_comment = PageComment.find(params[:id])   
   Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_delete", :item => PageComment.model_name.human, :name => @page_comment.page.title))                        
   flash[:success] = t("notice.item_delete_success", :item => PageComment.model_name.human)
   @page_comment.destroy
   redirect_to :back # go to page
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
  
  def page # Master Page Router 
    page = Page.find(params[:id])
    if page.published || @logged_in_user.is_admin? # make sure this is a published page they're going to
      if page.redirect # redirect? 
        redirect_to page.redirect_url 
      else # don't redirect, go to page.
        if page.page_type == "blog" # go to blog page
          redirect_to :action => "post", :controller => "blog", :id => page
        else # public page 
            redirect_to :action => "view", :id => page
        end      
      end
    else
      flash[:failure] = t("notice.not_visible")      
      redirect_to :action => "index", :controller => "browse"
    end 
  end
  
  def tinymce_images # show images to use with tinymce images
    @plugin = Plugin.find_by_name("Image") # use Images Plugin for titles and thumbnail settings      
    if params[:item_id] # get images for item
      @item = Item.find(params[:item_id])
      check_item_edit_permissions
      @images = PluginImage.find(:all, :conditions => ["item_id = ?", @item.id], :order => "created_at DESC")
    else # get images for system
      authenticate_admin # make sure they're an admin
      @images = Image.find(:all, :order => "created_at DESC")
    end 
    render :layout => false 
  end

  def upload_image  
      require "RMagick"
      @plugin = Plugin.find_by_name("Image") # use Images Plugin for title and thumbnail settings
      valid_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
      uploaded_file = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url])
      if uploaded_file
        filename = File.basename(uploaded_file.path)
        if Uploader.check_file_extension(:filename => filename, :extensions => valid_extensions)
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
                :path => Rails.root.to_s + "/public" + @image.url,          
                :thumbnail_path => Rails.root.to_s + "/public" + @image.thumb_url,
                :effects => params[:effects],
                :resize_image => @plugin.get_setting_bool("resize_item_images"),
                :resized_image_width => @plugin.get_setting("item_image_width").to_i,
                :resized_image_height => @plugin.get_setting("item_image_height").to_i,
                :thumbnail_width => @plugin.get_setting("item_thumbnail_width").to_i,
                :thumbnail_height => @plugin.get_setting("item_thumbnail_height").to_i
              ) 
            
              Log.create(:user_id => @logged_in_user.id,  :log_type => "new", :log => t("log.item_create", :item => Image.model_name.human , :name => filename))                 
              flash[:success] = t("notice.item_create_success", :item => PluginImage.model_name.human)  
              result = true
            else 
              flash[:failure] = t("notice.item_create_failure", :item => PluginImage.model_name.human)           
            end 
          else # save failed
            flash[:failure] = t("notice.item_create_failure", :item => PluginImage.model_name.human) 
          end
        else
          flash[:failure] = I18n.t("activerecord.errors.messages.invalid_file_extension", :valid_extensions => valid_extensions)
        end
    else # didn't select an image
      flash[:failure] =  Image.model_name.human + " " + t("notice.item_forgot_to_select", :item => @plugin.model_name.human)          
    end 
    (defined?(result) && result) ? render(:layout => false) : redirect_to(:action => "tinymce_images", :anchor => Image.model_name.human(:count => :other))
  end

  def delete_image
     @image = Image.find(params[:id])
     if @image.destroy
       Log.create(:user_id => @logged_in_user.id,  :log_type => "delete",  :log => t("log.item_delete", :item => Image.model_name.human, :name => File.basename(@image.url)))                        
       flash[:success] = t("notice.item_delete_success", :item => Image.model_name.human)    
     else # fail saved 
       flash[:failure] = t("notice.item_delete_failure", :item => Image.model_name.human)     
     end
    redirect_to :action => "tinymce_images"
  end  

  def view
     if params[:id] # A page number is set, show that page
       @page = Page.find(params[:id])   
       if @page.published || @logged_in_user.is_admin? # make sure this is a published page they're going to
           @setting[:meta_title] << @page.description if !@page.description.blank?
           @setting[:meta_title] << @page.title 
           @comments = PageComment.paginate :page => params[:page], :per_page => 25, :conditions => ["page_id = ? and is_approved = ?", @page.id, "1"]                  
       else
          flash[:failure] = "#{t("notice.not_visible")}"      
          redirect_to :action => "index", :controller => "browse"
       end   
     else 
       @page = nil
     end
  end  

  def send_contact_us
   if true#simple_captcha_valid?  
     email_regexp = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
     if !email_regexp.match(params[:email])# validate email
       flash[:failure] = "#{t("notice.invalid_email")}" #print out any errors!
     else # email okay
      #  def contact_us_email(recipient, from = "noemailset@none.com", name = "No Name Set", subject = "No Subject Set", message = "No Message Set", ip = "", display = "plain") 
      # Send Email
      Emailer.contact_us_email(params[:email], params[:name], t("email.subject.contact_us", :site_title => @setting[:title], :from => params[:name]), params[:message], request.env['REMOTE_ADDR']).deliver
      flash[:success] = "#{t("notice.contact_thanks", :name => params[:name])}" #print out any errors!
     end
   else # captcha failed
     flash[:failure] = t("notice.invalid_captcha") #print out any errors!
   end 
   redirect_to :action => "index", :controller => "browse"
  end  
  
   def update_order
    msg = String.new
    params[:ids].each_with_index do |id, position|
      page = Page.find(id) 
      page.update_attribute(:order_number, position)
    end
     Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => t("log.item_save", :item => Page.model_name.human, :name => Page.human_attribute_name(:order_number)))                                                 
     render :text => "<div class=\"notice\"><div class=\"success\">#{t("notice.save_success")}</div></div>"
   end 
end
