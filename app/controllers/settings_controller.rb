class SettingsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 
 
 def index
   @setting[:meta_title] = Setting.human_name.pluralize + " - " + t("section.title.admin").capitalize + " - " + @setting[:meta_title]
   @logo_image_exists = File.exists?(RAILS_ROOT + "/public/themes/#{@setting[:theme]}/images/logo.png")    # check if an existing logo image exists
 end

 def update_settings
   flash[:success] = "" 
   flash[:failure] = "" 
   params[:setting].each do |name, value| 
    # Dave: here were are querying the db once for EVERY setting in the table, just to get the setting name.
    # This is a little costly, the alternative being a find(:all) that is indexed with a integer-style counter
    # ie: @settings[counter], but the problem is that if the settings in the html form are listed in any 
    # different order, updating will do nothing, since the form setting and the indexed find(:all) won't match.
    # In the long run, this won't be too bad, since the size of the settings table shouldn't be very large(< 100)
    @setting = Setting.find(:first, :conditions => ["name = ?", name]) 
    if @setting.value != value # the value of the setting has changed
     if @setting.update_attribute("value", value) # update the setting
      flash[:success] << t("notice.item_save_success", :item => Setting.human_name + ": #{@setting.title}") 
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => t("log.item_save", :item => PluginSetting.human_name, :name => @setting.title))  # log it
     else # the setting failed saving 
      flash[:failure] << t("notice.item_save_failure", :item => Setting.human_name + ": #{@setting.title}") 
     end
    else # show that the setting hasn't changed
     #flash[:notice] << "<font color=grey>The Setting(#{name}) has not changed.<br></font>"
    end
   end
   redirect_to :action => "index"
  end
 
  def edit
  end

  def new
  end

  def new_change_logo
    @logo_image_exists = File.exists?(RAILS_ROOT + "/public/themes/#{@setting[:theme]}/images/logo.png")    # check if an existing logo image exists
  end
  
  def change_logo # change the main logo
     require "RMagick"
     require "net/http"
     require "open-uri" 
      
     proceed = false    
     
     acceptable_file_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
     uploaded_file = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url])
     filename = File.basename(uploaded_file.path)
     original_image = Magick::Image.from_blob(File.open(main_image_path).read).first # open original logo and create image object
     main_image_path = File.join(@setting[:theme_dir], "images", "logo.png") # location of main logo

     if params[:keep_dimensions] # keep original logo dimensions
        original_image = Magick::Image.from_blob(File.open(main_image_path).read).first # open original logo and create image object        
        width = original_image.columns
        height = original_image.rows
     end      
         
     if Uploader.check_file_extension(:filename => filename, :extensions => acceptable_file_extensions)
        Uploader.generate_image(
          :image => image,
          :path => main_image_path,          
          :resize_image => params[:keep_dimensions],
          :resized_image_width => width,
          :resized_image_height => height
        )           
        flash[:success] = t("notice.item_create_success", :item => t("single.main_image"))
        Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => t("log.item_create", :item => t("single.main_image"), :name => filename))  # log it
     else
        flash[:failure] = t("notice.invalid_file_extensions", :item => Image.human_name, :acceptable_file_extensions => acceptable_file_extensions)      
     end     

 
   redirect_to :action => "index", :controller => "settings"
  end

  def change_logo_old # change the main logo
     require "RMagick"
     require "net/http"
     require "open-uri" 
      
     proceed = false    
     if params[:file] != ""  && params[:url] == ""  #from their computer
      filename = params[:file].original_filename
      if check_image_format(filename) #the filename isn't valid
       image = Magick::Image.from_blob(params[:file].read).first    # read in image binary
       proceed = true
      else
       flash[:failure] = "#{params[:file].original_filename} upload failed! Please make sure that this is an image file, and that it ends in .png .jpg .jpeg .bmp or .gif  "     
      end 
     elsif params[:url] && !params[:file]  #from the web
      filename = File.basename(params[:url]) #.downcase # get the filename only
      if check_image_format(filename) #the filename is valid
       @url_file = open(params[:url]) # Open the image from net
       tmp_path = "#{RAILS_ROOT}/tmp" #location of the tmp folder
       FileUtils.mkdir_p(tmp_path) if !File.exist?(tmp_path) # create the tmp folder if it doesn't exist
       @file = open(tmp_path + "/" + filename, "wb") # open up the new file, binary style
       @file.write(@url_file.read) # copy the image
       if @file # temp file got copied successfully.
        @file.close # close tmp
        @file = open(tmp_path + "/" + filename, "rb") # reopen the temp file
        image = Magick::Image.from_blob(@file.read).first # read in image binary
        # Remove temp image
        FileUtils.rm(tmp_path + "/" + filename)
        proceed = true
       end
      else # filename isn't valid!
       flash[:failure] = "#{filename} upload failed! Please make sure that this is an image file, and that it ends in .png .jpg .jpeg .bmp or .gif  "     
      end
     elsif !params[:url].nil? && !params[:file].nil? #they accidentally did both
       flash[:failure] = "Please select <b>one</b> #{@plugin.name}, either from your computer or the web, <b>not both.</b> "     
        proceed = false
     else #random
       flash[:failure] = "Error Code: 1 Occurred!<br>#{params[:file].inspect} "     
       proceed = false
     end 
  
     if proceed # name okay, image object created
      main_image_path  = "#{RAILS_ROOT}/public/themes/#{@setting[:theme]}/images/logo.png" # location of main logo
      
      if params[:keep_dimensions] # keep original logo dimensions
        original_image = Magick::Image.from_blob(File.open(main_image_path).read).first # open original logo and create image object        
        image.crop_resized!( original_image.columns, original_image.rows) # resize
      end 
      
      FileUtils.rm(main_image_path) if File.exists?(main_image_path)# erase original
      image.write(main_image_path) # write new logo file 
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => "New Logo Updated.") # log it
      flash[:success] = "New Logo Added successfully!"     
     end
 
   redirect_to :action => "index", :controller => "settings"
  end



  def delete_logo # delete the main logo, so opal will display text instead
    main_image_path = File.join(@setting[:theme_dir], "images", "logo.png") # location of main logo
    if File.exists?(main_image_path) # check if logo exists
      FileUtils.rm(logo_path)
      flash[:success] = t("notice.item_delete_success", :item => t("single.main_image"))
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => t("log.item_delete", :item => t("single.main_image"), :name => File.basename(main_image_path)))  # log it      
    else # no logo exists
      flash[:success] = t("notice.file_not_found", :file => main_image_path) 
    end
    redirect_to :action => "index", :controller => "settings", :anchor => "Logo"
  end
  
  def themes
   @themes = Array.new
   themes_dir = File.join(@setting[:theme_dir], "..")  # the folder containing the themes
   Dir.new(themes_dir).entries.each do |file|
     if (file.to_s != ".") && (file != "..")
      @themes << file
     end 
   end    
  end
  
  def install_theme # install a theme into opal 
    # Note: Theme zip files will be extracted into a directory with the same filename as the zipfile(ie: example_theme.zip -> public/themes/example_theme)
    zipfile = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url]) 
    acceptable_file_extensions = ".zip, .ZIP"
    if Uploader.check_file_extension(:filename => File.basename(zipfile.path), :extensions => acceptable_file_extensions) # make sure file is a zipped archive 
      unzipped_theme_dir = Uploader.extract_zip_to_tmp(zipfile.path).entries[0].to_s # extract zip file to tmp
      theme_config_file = File.join(unzipped_theme_dir, "theme.yml")
      if File.exists?(theme_config_file)
        theme_config = YAML::load(File.open(theme_config_file)) # get theme configuration          
        themes_dir = File.join(RAILS_ROOT, "public/themes") 
        if FileUtils.mv(unzipped_theme_dir, themes_dir) # move tmp theme dir into the real themes dir
           flash[:success] = t("notice.item_install_success", :item => t("single.theme")) 
           Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("log.item_install", :item => t("single.theme"), :name => theme_config["theme"]["name"])) # log it
        end        
      else # no theme config file found 
        flash[:failure] = t("notice.item_install_failure", :item => t("single.theme"))
        flash[:failure] += "<br>" + t("notice.file_not_found", :file => theme_config_file)        
      end
    else # bad file extension
      flash[:failure] = t("notice.item_install_failure", :item => t("single.theme"))
      flash[:failure] += t("notice.invalid_file_extensions", :item => t("single.theme"), :acceptable_file_extensions => acceptable_file_extensions)      
    end 
    redirect_to :action => "themes"
  ensure 
    FileUtils.rm_rf(zipfile.path) # remove zip file    
  end
 
  def delete_theme
    theme = params[:theme]
    if theme == @setting[:theme] # they are trying to delete the active theme
      flash[:failure] = t("notice.invalid_permissions")           
      #flash[:failure] = "Sorry, you can't delete the active theme! Please change your theme first."     
    else 
      themes_dir = RAILS_ROOT + "/public/themes"
      theme_dir = themes_dir + "/" + theme
      theme_config_file = File.join(theme_dir, "theme.yml")
      theme_config = YAML::load(File.open(theme_config_file)) # get theme configuration    
           
      themes_layout_dir = RAILS_ROOT + "/app/views/layouts/themes"
      theme_layout_dir = themes_layout_dir + "/" + theme 
      FileUtils.rm_rf (theme_dir) if File.exists?(theme_dir)# erase theme directory
      FileUtils.rm_rf (theme_layout_dir) if File.exists?(theme_layout_dir)# erase theme layout directory, if it exists      
      flash[:failure] = t("notice.item_uninstall_success", :item => t("single.theme"))
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("log.item_uninstall", :item => t("single.theme"), :name => theme_config["theme"]["name"])) # log it
    end
    
    redirect_to :action => "themes"
  end
  
  


end
