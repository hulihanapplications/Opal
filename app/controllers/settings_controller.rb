class SettingsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 
 
 def index
   @setting[:meta_title] = "Settings - Admin - "+ @setting[:meta_title]
   @logo_image_exists = File.exists?(RAILS_ROOT + "/public/themes/#{@setting[:theme]}/images/logo.png")    # check if an existing logo image exists
 end

 def update_settings
   flash[:notice] = "<div class=\"flash_success\">" 
   params[:setting].each do |name, value| 
    # Dave: here were are querying the db once for EVERY setting in the table, just to get the setting name.
    # This is a little costly, the alternative being a find(:all) that is indexed with a integer-style counter
    # ie: @settings[counter], but the problem is that if the settings in the html form are listed in any 
    # different order, updating will do nothing, since the form setting and the indexed find(:all) won't match.
    # In the long run, this won't be too bad, since the size of the settings table shouldn't be very large(< 100)
    @setting = Setting.find(:first, :conditions => ["name = ?", name]) 
    if @setting.value != value # the value of the setting has changed
     if @setting.update_attribute("value", value) # update the setting
      flash[:notice] << "The setting: <b>#{@setting.title}</b> was updated!<br>"
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => "The #{@setting.title} setting was changed to #{value}.") # log it
     else # the setting failed saving 
      flash[:notice] << "<font color=red>The setting: <b>#{@setting.title}</b> failed updating!</font><br>"
     end
    else # show that the setting hasn't changed
     #flash[:notice] << "<font color=grey>The Setting(#{name}) has not changed.<br></font>"
    end
   end
   flash[:notice] << "</div>"
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
     if params[:file] != ""  && params[:url] == ""  #from their computer
      filename = params[:file].original_filename
      if check_image_format(filename) #the filename isn't valid
       image = Magick::Image.from_blob(params[:file].read).first    # read in image binary
       proceed = true
      else
       flash[:notice] = "<div class=\"flash_failure\">#{params[:file].original_filename} upload failed! Please make sure that this is an image file, and that it ends in .png .jpg .jpeg .bmp or .gif </div> "     
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
       flash[:notice] = "<div class=\"flash_failure\">#{filename} upload failed! Please make sure that this is an image file, and that it ends in .png .jpg .jpeg .bmp or .gif </div> "     
      end
     elsif !params[:url].nil? && !params[:file].nil? #they accidentally did both
       flash[:notice] = "<div class=\"flash_failure\">Please select <b>one</b> #{@plugin.name}, either from your computer or the web, <b>not both.</b></div> "     
        proceed = false
     else #random
       flash[:notice] = "<div class=\"flash_failure\">Error Code: 1 Occurred!<br>#{params[:file].inspect}</div> "     
       proceed = false
     end 
  
     if proceed # name okay, image object created
      main_logo_path  = "#{RAILS_ROOT}/public/themes/#{@setting[:theme]}/images/logo.png" # location of main logo
      
      if params[:keep_dimensions] # keep original logo dimensions
        original_image = Magick::Image.from_blob(File.open(main_logo_path).read).first # open original logo and create image object        
        image.crop_resized!( original_image.columns, original_image.rows) # resize
      end 
      
      FileUtils.rm(main_logo_path) if File.exists?(main_logo_path)# erase original
      image.write(main_logo_path) # write new logo file 
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => "New Logo Updated.") # log it
      flash[:notice] = "<div class=\"flash_success\">New Logo Added successfully!</div>"     
     end
 
   redirect_to :action => "index", :controller => "settings"
  end

  def delete_logo # delete the main logo, so opal will display text instead
    logo_path = RAILS_ROOT + "/public/themes/#{@setting[:theme]}/images/logo.png"
    if File.exists?(logo_path) # check if logo exists
      FileUtils.rm(logo_path)
      flash[:notice] = "<div class=\"flash_success\">Logo deleted successfully!</div>"
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => "Logo Deleted.") # log it
    else # no logo exists
      flash[:notice] = "<div class=\"flash_success\">No Existing logo found!</div>"
    end
    redirect_to :action => "index", :controller => "settings", :anchor => "Logo"
  end
  
  def themes
   @themes = Array.new
   themes_folder = RAILS_ROOT + "/public/themes" # the folder containing the themes
   Dir.new(themes_folder).entries.each do |file|
     if (file.to_s != ".") && (file != "..")
      @themes << file
     end 
   end    
  end
  
  def install_theme # install a theme into opal 
    # Note: Theme zip files will be extracted into a directory with the same filename as the zipfile(ie: example_theme.zip -> public/themes/example_theme)
    zipfile = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url]) 
    if Uploader.check_file_extension(:filename => File.basename(zipfile.path), :extensions => ".zip, .ZIP") # make sure file is a zipped archive 
      unzipped_theme_dir = Uploader.extract_zip_to_tmp(zipfile.path).entries[0].to_s # extract zip file to tmp
      theme_config_file = File.join(unzipped_theme_dir, "theme.yml")
      if File.exists?(theme_config_file)
        theme_config = YAML::load(File.open(theme_config_file)) # get theme configuration          
        themes_dir = File.join(RAILS_ROOT, "public/themes") 
        if FileUtils.mv(unzipped_theme_dir, themes_dir) # move tmp theme dir into the real themes dir
          flash[:notice] = "<div class=\"flash_success\">A New theme, <b>#{theme_config["theme"]["name"]}</b>, has been installed!</div>"
          Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => "Installed Theme: #{theme_config["theme"]["name"]}.") # log it
        end        
      else # no theme config file found 
        flash[:notice] = "<div class=\"flash_failure\">This theme could not be installed because <b>#{File.basename(theme_config_file)}</b> could not be found in #{unzipped_theme_dir}! </div>"                   
      end
    else # bad file extension
      flash[:notice] = "<div class=\"flash_failure\">#{Basename(zipfile.path)} upload failed! Please make sure that this is a zip file, and that it ends in .zip or .ZIP </div>"           
    end 
    redirect_to :action => "themes"
  ensure 
    FileUtils.rm_rf(zipfile.path) # remove zip file    
  end
 
  def delete_theme
    theme = params[:theme]
    if theme == @setting[:theme] # they are trying to delete the active theme
      flash[:notice] = "<div class=\"flash_failure\">Sorry, you can't delete the active theme! Please change your theme first.</div>"     
    else 
      themes_dir = RAILS_ROOT + "/public/themes"
      theme_dir = themes_dir + "/" + theme
      theme_config_file = File.join(theme_dir, "theme.yml")
      theme_config = YAML::load(File.open(theme_config_file)) # get theme configuration    
           
      themes_layout_dir = RAILS_ROOT + "/app/views/layouts/themes"
      theme_layout_dir = themes_layout_dir + "/" + theme 
      FileUtils.rm_rf (theme_dir) if File.exists?(theme_dir)# erase theme directory
      FileUtils.rm_rf (theme_layout_dir) if File.exists?(theme_layout_dir)# erase theme layout directory, if it exists      
      flash[:notice] = "<div class=\"flash_success\">The theme, <b>#{theme_config["theme"]["name"]}</b>, was deleted.</div>"
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => "Deleted Theme: #{theme_config["theme"]["name"]}.") # log it      
    end
    
    redirect_to :action => "themes"
  end
  
  
private
   def check_image_format(filename)
    extensions = /.png|.jpg|.jpeg|.gif|.bmp|.tiff|.PNG|.JPG|.JPEG|.GIF|.BMP|.TIFF$/ #define the accepted regexs
    return extensions.match(filename)   # return false or true if matched
  end

end
