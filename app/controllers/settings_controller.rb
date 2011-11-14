class SettingsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 
 after_filter :reload_settings, :only => [:update_settings]
 
 def index
   @setting[:meta_title] << Setting.model_name.human(:count => :other)
   @logo_image_exists = File.exists?(Rails.root.to_s + "/public/themes/#{@setting[:theme]}/images/logo.png")    # check if an existing logo image exists
 end

 def update_settings
   flash[:success] = "" 
   flash[:failure] = "" 
   counter = 0
   params[:setting].each do |name, value| 
    @setting = Setting.find(:first, :conditions => ["name = ?", name]) 
    if @setting.value != value # the value of the setting has changed
     if @setting.update_attribute("value", value) # update the setting
      flash[:success] << t("notice.item_save_success", :item => Setting.model_name.human + ": #{@setting.title}") + "<br />" 
      log(:log_type => "system", :log => t("log.item_save", :item => Setting.model_name.human, :name => @setting.title))  # log it
     else # the setting failed saving 
      flash[:failure] << t("notice.item_save_failure", :item => Setting.model_name.human + ": #{@setting.title}")  + "<br />" 
     end
    
     counter += 1 
    else # show that the setting hasn't changed
     #flash[:notice] << "<font color=grey>The Setting(#{name}) has not changed.<br></font>"
    end
   end
   redirect_to :back
  end
 
  def edit
  end

  def new
  end

  def new_change_logo
    @logo_image_exists = File.exists?(Rails.root.to_s + "/public/themes/#{@setting[:theme]}/images/logo.png")    # check if an existing logo image exists
  end
  
  def change_logo # change the main logo
     require "RMagick"
     require "net/http"
     require "open-uri" 
      
     proceed = false    
     
     acceptable_file_extensions = ".png, .jpg, .jpeg, .gif, .bmp, .tiff, .PNG, .JPG, .JPEG, .GIF, .BMP, .TIFF"
     uploaded_file = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url])
     filename = params[:file].blank? ? File.basename(uploaded_file.path) : params[:file].original_filename 
     main_image_path = File.join(@setting[:theme_dir], "images", "logo.png") # location of main logo

     if params[:keep_dimensions] # keep original logo dimensions
        original_image = Magick::Image.from_blob(File.open(main_image_path).read).first # open original logo and create image object        
        width = original_image.columns
        height = original_image.rows
     end      
     
     if Uploader.check_file_extension(:filename => filename, :extensions => acceptable_file_extensions)
        image = Magick::Image.from_blob(File.open(uploaded_file.path).read)[0] # read in image binary, from_blob returns an array of images, grab first item
        Uploader.generate_image(
          :image => image,
          :path => main_image_path,          
          :resize_image => params[:keep_dimensions],
          :resized_image_width => width,
          :resized_image_height => height,
          :generate_thumbnail => false
        )           
        flash[:success] = t("notice.item_create_success", :item => t("single.logo"))
        log(:log_type => "system", :log => t("log.item_create", :item => t("single.logo"), :name => filename))  # log it
     else
        flash[:failure] = t("single.logo") + " " + t("activerecord.errors.messages.invalid_file_extension", :valid_extensions => acceptable_file_extensions)      
     end

 
   redirect_to :action => "index", :controller => "settings"
  end




  def delete_logo # delete the main logo, so opal will display text instead
    main_image_path = File.join(@setting[:theme_dir], "images", "logo.png") # location of main logo
    if File.exists?(main_image_path) # check if logo exists
      FileUtils.rm(main_image_path)
      flash[:success] = t("notice.item_delete_success", :item => t("single.logo"))
      log(:log_type => "system", :log => t("log.item_destroy", :item => t("single.logo"), :name => File.basename(main_image_path)))  # log it      
    else # no logo exists
      flash[:success] = t("notice.file_not_found", :file => main_image_path) 
    end
    redirect_to :action => "index", :controller => "settings", :anchor => "Logo"
  end
  
  def themes
   @themes = Array.new
   Dir.new(@setting[:themes_dir]).entries.each do |file|
     if (file.to_s != ".") && (file != "..")
      @themes << file
     end 
   end    
  end
  
  def install_theme # install a theme into opal 
    # Note: Theme zip files will be extracted into a directory with the same filename as the zipfile(ie: example_theme.zip -> public/themes/example_theme)
    zipfile = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url]) 
    acceptable_file_extensions = ".zip, .ZIP"
    if true #Uploader.check_file_extension(:filename => File.basename(zipfile.path), :extensions => acceptable_file_extensions) # make sure file is a zipped archive 
			zip_dir = Uploader.extract_zip_to_tmp(zipfile.path)
			extract_dir = Dir.actual_entries(zip_dir)[0].to_s # extract zip file to tmp
			extract_dir_entries = Dir.actual_entries(File.join(zip_dir, extract_dir))
			unzipped_theme_dir = extract_dir_entries.size == 1 ? File.join(extract_dir, extract_dir_entries[0]) : File.join(zip_dir, extract_dir)  # Get the dir that actually contains the theme files
      theme_config_file = File.expand_path(File.join(unzipped_theme_dir, "theme.yml"))
      if File.exists?(theme_config_file)
        theme_config = YAML::load(File.open(theme_config_file)) # get theme configuration          
        themes_dir = File.join(Rails.root.to_s, "public/themes") 
        if FileUtils.mv(unzipped_theme_dir, themes_dir) # move tmp theme dir into the real themes dir
           flash[:success] = t("notice.item_install_success", :item => t("single.theme")) 
           log(:log_type => "create", :log => t("log.item_install", :item => t("single.theme"), :name => theme_config["theme"]["name"])) # log it
        end        
      else # no theme config file found 
        flash[:failure] = t("notice.item_install_failure", :item => t("single.theme"))
        flash[:failure] += "<br>" + t("notice.file_not_found", :file => theme_config_file)
      end
    else # bad file extension
      flash[:failure] = t("notice.item_install_failure", :item => t("single.theme"))
      flash[:failure] += I18n.t("activerecord.errors.messages.invalid_file_extension", :valid_extensions => acceptable_file_extensions)
    end 
    redirect_to :action => "themes"
  ensure 
    FileUtils.rm_rf(zipfile.path) # remove zip file    
  end
 
  def delete_theme
    theme = params[:theme_name]
    if theme == @setting[:theme] # they are trying to delete the active theme
      flash[:failure] = t("notice.invalid_permissions")          
      #flash[:failure] = "Sorry, you can't delete the active theme! Please change your theme first."     
    else 
      themes_dir = Rails.root.to_s + "/public/themes"
      theme_dir = themes_dir + "/" + theme
      theme_config_file = File.join(theme_dir, "theme.yml")
      theme_config = YAML::load(File.open(theme_config_file)) # get theme configuration    
           
      themes_layout_dir = Rails.root.to_s + "/app/views/layouts/themes"
      theme_layout_dir = themes_layout_dir + "/" + theme 
      FileUtils.rm_rf(theme_dir) if File.exists?(theme_dir)# erase theme directory
      FileUtils.rm_rf(theme_layout_dir) if File.exists?(theme_layout_dir)# erase theme layout directory, if it exists      
      flash[:success] = t("notice.item_uninstall_success", :item => t("single.theme"))
      log(:log_type => "destroy", :log => t("log.item_uninstall", :item => t("single.theme"), :name => theme_config["theme"]["name"])) # log it
    end
    
    redirect_to :action => "themes"
  end
  
  


end
