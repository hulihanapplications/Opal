class PluginsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin  
 before_filter :enable_admin_menu # show admin menu 
 after_filter :reload_plugins # reload cached plugins
 protect_from_forgery :except => [:enable_disable_plugin]


  
   def index
     @setting[:meta_title] <<  Plugin.model_name.human(:count => :other)  
     @plugins = Plugin.find(:all, :order => "order_number ASC")
     @setting[:ui] = true
   end
    
   def update_order
    params[:ids].each_with_index do |id, position|
      plugin = Plugin.update(id, :order_number => position)
    end
     Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => t("log.item_save", :item => Plugin.model_name.human, :name => Plugin.human_attribute_name(:order_number)))                                                 
     render :text => "<div class=\"notice\"><div class=\"success\">#{t("notice.save_success")}</div></div>"
   end 
   
   
   def toggle_plugin
      plugin = Plugin.find(params[:id])
      if plugin.is_enabled == "1"
        plugin.is_enabled = "0"
        msg = t("log.item_disable", :item => Plugin.model_name.human, :name => plugin.model_name.human(:count => :other)) 
      elsif plugin.is_enabled == "0"
        plugin.is_enabled = "1"
        msg = t("log.item_enable", :item => Plugin.model_name.human, :name => plugin.model_name.human(:count => :other)) 
      end
      plugin.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => msg)                                              
      render :text => "<div class=\"notice\"><div class=\"success\">#{msg}</div></div>"
   end
   
   def settings
     @plugin = Plugin.find(params[:id])
   end
       
   def update_plugin_settings # update plugin settings
     flash[:success] = "" 
     params[:setting].each do |name, value| 
      @setting = PluginSetting.find(:first, :conditions => ["name = ?", name]) 
      if @setting.value != value # the value of the setting has changed
       if @setting.update_attribute("value", value) # update the setting
        flash[:success] << t("notice.item_save_success", :item => PluginSetting.model_name.human + ": #{@setting.title}") + "<br>"
        Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => t("log.item_save", :item => PluginSetting.model_name.human, :name => @setting.title))                                                 
       else # the setting failed saving 
        flash[:failure] << t("notice.item_save_failure", :item => PluginSetting.model_name.human + ": #{@setting.title}")
       end
      else # show that the setting hasn't changed
       #flash[:notice] << "<font color=grey>The Setting(#{name}) has not changed.<br></font>"
      end
     end
     redirect_to :action => "index"
    end
    

    
    def new_install
      @setting[:load_prototype] = true # load prototype js in layout, this action doesn't use prototype, but it disables jquery tabs, which we want.    
    end
    
    def install 
      logger.info params[:file].path
      zipfile = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url]) 
      
      if true #Uploader.check_file_extension(:filename => File.basename(zipfile.path), :extensions => ".zip, .ZIP") # make sure file is a zipped archive 
        extract_dir = Uploader.extract_zip_to_tmp(zipfile.path) # extract zip file to tmp
        extract_dir_entries = Dir.entries(extract_dir); extract_dir_entries.delete("."); extract_dir_entries.delete("..") # remove system/hidden dirs from entries list 
        unzipped_plugin_dir = extract_dir_entries.size == 1 ? File.join(extract_dir, extract_dir_entries[0]) : extract_dir  # Get the dir that actually contains the plugin
        plugin_model_name = File.basename(unzipped_plugin_dir) # model name must be same as zipped file
        plugin = plugin_mode_name.constantize
        plugin_model_path = File.join(unzipped_plugin_dir, "app", "models", "#{plugin_model_name}.rb")
        if File.exists?(plugin_model_path) # if the .rb model file was found 
          require plugin_model_path # load up new plugin's model/class 
                     
          if plugin.install # run new plugin model's install method
            # Install files 
            for file in  plugin.install.files 
              FileUtils.mkdir_p(File.dirname(File.join(Rails.root.to_s, file))) if !File.exists?(File.dirname(File.join(Rails.root.to_s, file))) # create directory if it doesn't exist
              FileUtils.cp_r(File.join(unzipped_plugin_dir, file), File.join(Rails.root.to_s, file)) # install file
            end
            flash[:success] = t("notice.item_install_success", :item => Plugin.model_name.human) 
            Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("notice.item_install", :item => Plugin.model_name.human, :name => plugin.model_name.human)) # log it
          else 
            flash[:failure] = t("notice.item_install_failure", :item => Plugin.model_name.human)                             
          end        
        else # no plugin model .rb file found 
          flash[:failure] = t("notice.file_not_found", :file => plugin_model_path) 
        end
      else # bad file extension
        flash[:failure] = t("notice.item_install_failure", :item => Plugin.model_name.human) #"#{File.basename(zipfile.path)} upload failed! Please make sure that this is a zip file, and that it ends in .zip or .ZIP "           
      end 
      redirect_to :action => "index"   
    ensure
      FileUtils.rm_rf(zipfile.path) # delete tmp zipfile                                
      FileUtils.rm_rf(unzipped_plugin_dir) # delete tmp extraction directory                          
    end
  
    def uninstall
      @plugin = Plugin.find(params[:id])
      if !@plugin.is_builtin? # make sure they're not trying to uninstall a builtin plugin
        plugin =  ("Plugin" + @plugin.name.classify).constantize # get the class for this plugin 
        if plugin.uninstall # call model's uninstall method
          for file in plugin.files # uninstall files 
            FileUtils.rm_rf(File.join(Rails.root.to_s, file)) if File.exists?(File.join(Rails.root.to_s, file)) # uninstall file
          end         
          flash[:success] = t("notice.item_uninstall_success", :item => Plugin.model_name.human)
          Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("notice.item_uninstall", :item => Plugin.model_name.human, :name => plugin.model_name.human)) # log it
        else 
          flash[:success] = t("notice.item_uninstall_failure", :item => Plugin.model_name.human)
        end
      else # trying to unistall builtin plugin
        flash[:failure] = t("notice.invalid_permissions")                  
      end 
      redirect_to :action => "index"            
    end

end

