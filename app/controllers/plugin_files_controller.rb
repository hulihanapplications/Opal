class PluginFilesController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "File"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
      flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div>"
      redirect_to :action => "view", :controller => "items", :id => @item.id        
   end
 end


 
  def create
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions       
     @file = PluginFile.new
     @file.user_id = @logged_in_user.id
     @file.item_id = @item.id
     @file.title = params[:file_title]
     
     if params[:file] != "" # && params[:url] == ""  #from their computer
       filename = clean_filename(params[:file].original_filename)
       @file.filename = filename
 
       #write the file
       folder_path = File.dirname(@file.path)
       FileUtils.mkdir_p(folder_path) if !File.exist?(folder_path) # create the folder if it doesn't exist
       @file.size = (File.size(params[:file]) / 1000).to_s + "kb" # get filesize
       
       f = File.new(@file.path, "wb") # open new file
       f.write params[:file].read # write the file
       f.close # close the file

       # Set Approval
       @file.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
      
       if @file.save
        Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Uploaded #{@file.filename}.")         
        flash[:notice] = "<div class=\"flash_success\">New #{@plugin.title}: <b>#{@file.filename}</b> added!</div>"
        flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !@file.is_approved?
       else # fail saved 
        flash[:notice] = "<div class=\"flash_failure\">This #{@plugin.title} could not be added! Here's why:<br>#{print_errors(@file)}</div>"
        
       end 
     else # 
      flash[:notice] = "<div class=\"flash_failure\">Please select a #{@plugin.title} from your computer.</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"        
   end 
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end


  
  def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions       
     @file = PluginFile.find(params[:file_id])
     if @file.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted #{@file.filename}.")                
      flash[:notice] = "<div class=\"flash_success\"><b>#{@file.title}</b> Deleted!</div>"
     else # fail saved 
      flash[:notice] = "<div class=\"flash_success\">Delete Failed!"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div>"        
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end

  def download
   @file = PluginFile.find(params[:id])    
   @item = Item.find(@file.item_id)
   if @item.is_viewable_for_user?(@logged_in_user)
    if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           
      if (@plugin.get_setting_bool("login_required_for_download") && @logged_in_user.id != 0) || (!@plugin.get_setting_bool("login_required_for_download"))# are logins required for downloading?
        if @plugin.get_setting_bool("log_downloads") # log this download?
          Log.create(:user_id => @logged_in_user.id, :item_id => @item.id, :log_type => "download", :log => "Downloaded #{@file.filename}.") if @logged_in_user.id != 0 # msg if a user is logged in
          Log.create(:item_id => @item.id, :log_type => "download", :log => "A visitor from #{request.env["REMOTE_ADDR"]} downloaded #{@file.filename}.") if @logged_in_user.id == 0  # msg if a user is logged in
        end  
        @file.update_attribute(:downloads, @file.downloads + 1) # increment downloads
        send_file @file.path
      else # they must be logged in to download this file
        authenticate_user
      end 
    else # Improper Permissions  
      flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot view #{@plugin.title}s.</div>"        
    end    
   else # Attempted Securtiy Bypass: User is trying to download an item from an item that's not viewable. 
    flash[:notice] = "<div class=\"flash_failure\">Sorry, this item isn't viewable by you.</div>"
    redirect_to :action => "index", :controller => "/browse"
   end  
 end

 
 def change_approval
    @file = PluginFile.find(params[:file_id])    
    if  @file.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@file.user.username}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@file.user.username}."
    end
    
    if @file.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div>"
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end

private

   def clean_filename(filename) 
    @bad_chars = ['&', '\+', '%', '!', ' ', '/'] #string of bad characters
    for char in @bad_chars
     filename = filename.gsub(/#{char}/, "_") # replace the bad chars with good ones!
    end
    return filename 
   end
end
