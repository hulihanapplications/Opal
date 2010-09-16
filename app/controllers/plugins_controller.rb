class PluginsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin  
 before_filter :enable_admin_menu # show admin menu 
 
 protect_from_forgery :except => [:enable_disable_plugin]


  
   def index
     @setting[:meta_title] = "Plugins - Admin - "+ @setting[:meta_title]
     @setting[:load_prototype] = true # load prototype js in layout 
     @plugins = Plugin.find(:all, :order => "order_number ASC")
   end
    
   def update_plugins_order
    params[:sortable_list].each_with_index do |id, position|
      plugin = Plugin.update(id, :order_number => position)
    end
     Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => "Plugin Order Updated.")                                                 
    render :text => "<div class=\"flash_success\">Order Updated!</div>"
   end 
   
   
   def enable_disable_plugin
      plugin = Plugin.find(params[:id])
      if plugin.is_enabled == "1"
        plugin.is_enabled = "0"
        msg = "#{plugin.name}s Disabled!"
      elsif plugin.is_enabled == "0"
        plugin.is_enabled = "1"
        msg = "#{plugin.name}s Enabled!"
      end
      plugin.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => msg)                                              
      render :text => "<div class=\"flash_success\">#{msg}</div>"
   end
       
   def update_plugin_settings # update plugin settings
     flash[:notice] = "<div class=\"flash_success\">" 
     params[:setting].each do |name, value| 
      @setting = PluginSetting.find(:first, :conditions => ["name = ?", name]) 
      if @setting.value != value # the value of the setting has changed
       if @setting.update_attribute("value", value) # update the setting
        flash[:notice] << "The setting: <b>#{@setting.title}</b> was updated!<br>"
       else # the setting failed saving 
        flash[:notice] << "<font color=red>The setting:<b>#{@setting.title}</b> failed updating!</font><br>"
       end
      else # show that the setting hasn't changed
       #flash[:notice] << "<font color=grey>The Setting(#{name}) has not changed.<br></font>"
      end
     end
     flash[:notice] << "</div>"
     redirect_to :action => "index"
    end
    
    def update_plugin_title
      item = Plugin.find(params[:id])    
      log_msg = "Plugin Title changed from #{item.title} to #{params[:plugin_title]}"
      item.update_attribute(:title, params[:plugin_title])
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => log_msg)                                                   
      render :text => "<h2>#{item.title}s <font size=1><a href=\"javascript:replace_box('plugin_title_#{item.id}','edit_plugin_title_#{item.id}')\">(Edit Name)</a></font></h2>"
      #render :text => "#{item.title}"
    end
    
    def new_install
      @setting[:load_prototype] = true # load prototype js in layout, this action doesn't use prototype, but it disables jquery tabs, which we want.    
    end
    
    def install 
      logger.info params[:file].path
      zipfile = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url]) 
      
      if Uploader.check_file_extension(:filename => File.basename(zipfile.path), :extensions => ".zip, .ZIP") # make sure file is a zipped archive 
        unzipped_plugin_dir = Uploader.extract_zip_to_tmp(zipfile.path) # extract zip file to tmp
        plugin_model_name = File.basename(unzipped_plugin_dir) # model name must be same as zipped file
        plugin_model_path = File.join(unzipped_plugin_dir, "app", "models", "#{plugin_model_name}.rb")
        if File.exists?(plugin_model_path) # if the .rb model file was found 
          require plugin_model_path # load up new plugin's model/class            
          if plugin_model_name.classify.constantize.install # run new plugin model's install method
            # Install files 
            for file in plugin_model_name.classify.constantize.files 
              FileUtils.mkdir_p(File.dirname(File.join(RAILS_ROOT, file))) if !File.exists?(File.dirname(File.join(RAILS_ROOT, file))) # create directory if it doesn't exist
              FileUtils.cp_r(File.join(unzipped_plugin_dir, file), File.join(RAILS_ROOT, file)) # install file
            end
            flash[:notice] = "<div class=\"flash_success\">A new plugin, <b>#{plugin_model_name.classify}</b>, has been installed!</div>"
            Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => "Installed Plugin: #{plugin_model_name.classify}") # log it
          else 
            flash[:notice] = "<div class=\"flash_failure\">There was a problem installing this plugin! </div>"                               
          end        
        else # no plugin model .rb file found 
          flash[:notice] = "<div class=\"flash_failure\">This plugin could not be installed because <b>#{File.basename(plugin_model_path)}</b> could not be found in #{File.dirname(unzipped_plugin_dir)}! </div>"                   
        end
      else # bad file extension
        flash[:notice] = "<div class=\"flash_failure\">#{File.basename(zipfile.path)} upload failed! Please make sure that this is a zip file, and that it ends in .zip or .ZIP </div>"           
      end 
      redirect_to :action => "index"   
    ensure
      FileUtils.rm_rf(zipfile.path) # delete tmp zipfile                                
      FileUtils.rm_rf(unzipped_plugin_dir) # delete tmp extraction directory                          
    end
  
    def uninstall
      @plugin = Plugin.find(params[:id])
      if !@plugin.is_builtin? # make sure they're not trying to uninstall a builtin plugin
        plugin_class =  ("Plugin" + @plugin.name.classify).constantize # get the class for this plugin 
        if plugin_class.uninstall # call model's uninstall method
          for file in plugin_class.files # uninstall files 
            FileUtils.rm_rf(File.join(RAILS_ROOT, file)) if File.exists?(File.join(RAILS_ROOT, file)) # uninstall file
          end         
          flash[:notice] = "<div class=\"flash_success\">The <b>#{@plugin.title}s</b> plugin has been uninstalled.</div>"
          Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => "Uninstalled Plugin: #{@plugin.title}") # log it            
        else 
          flash[:notice] = "<div class=\"flash_failure\">There was a problem uninstalling the #{@plugin.title} Plugin.</div>"                   
        end
      else 
        flash[:notice] = "<div class=\"flash_failure\">You're not allowed to uninstall a built-in plugin!</div>"                   
      end 
      redirect_to :action => "index"            
    end

end

