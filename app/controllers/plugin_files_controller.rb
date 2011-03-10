class PluginFilesController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item, :except => [:download] # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 require "uploader"


 
  def create
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions
     @file = PluginFile.new
     @file.user_id = @logged_in_user.id
     @file.item_id = @item.id
     @file.title = params[:file_title]
     
     uploaded_file = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url])
     if uploaded_file
       filename = Uploader.clean_filename(File.basename(uploaded_file.path))
       @file.filename = filename
 
       #write the file
       folder_path = File.dirname(@file.path)
       FileUtils.mkdir_p(folder_path) if !File.exist?(folder_path) # create the folder if it doesn't exist
       @file.size = (File.size(uploaded_file) / 1000).to_s + "kb" # get filesize
       
       f = File.new(@file.path, "wb") # open new file
       f.write uploaded_file.read # write the file
       f.close # close the file

       # Set Approval
       @file.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
      
       if @file.save
        Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => filename))         
        flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
        flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@file.is_approved?
       else # fail saved 
        flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
        
       end 
     else # No file/url submitted 
      flash[:failure] = t("notice.item_not_found", :item => @plugin.model_name.human)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")           
   end 
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end


  
  def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions       
     @file = PluginFile.find(params[:file_id])
     if @file.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human, :name => @file.filename))                
      flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
     else # fail saved 
      flash[:success] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")        
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
 end

  def download
   @file = PluginFile.find(params[:id])    
   @item = Item.find(@file.item_id)
   if @item.is_viewable_for_user?(@logged_in_user)
    if @my_group_plugin_permissions.can_read? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions           
      if (@plugin.get_setting_bool("login_required_for_download") && !@logged_in_user.anonymous?) || (!@plugin.get_setting_bool("login_required_for_download"))# are logins required for downloading?
        if @plugin.get_setting_bool("log_downloads") # log this download?
          Log.create(:user_id => @logged_in_user.id, :item_id => @item.id, :log_type => "download", :log => t("log.item_downloaded_by_user", :item => @plugin.model_name.human, :name => @file.filename)) if !@logged_in_user.anonymous? # msg if a user is logged in
          Log.create(:item_id => @item.id, :log_type => "download", :log => t("log.item_downloaded_by_visitor", :item => @plugin.model_name.human, :name => @file.filename, :ip => request.env["REMOTE_ADDR"])) if @logged_in_user.anonymous?  # msg if a user is logged in
        end  
        @file.update_attribute(:downloads, @file.downloads + 1) # increment downloads
        send_file @file.path
      else # they must be logged in to download this file
        authenticate_user
      end 
    else # Improper Permissions  
      flash[:failure] = t("notice.invalid_permissions")         
    end    
   else # Attempted Securtiy Bypass: User is trying to download an item from an item that's not viewable. 
    flash[:failure] = t("notice.not_visible") 
    redirect_to :action => "index", :controller => "browse"
   end  
 end

 
 def change_approval
    @file = PluginFile.find(params[:file_id])    
    if  @file.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.model_name.human, :name => @file.filename)
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @plugin.model_name.human, :name => @file.filename)
    end
    
    if @file.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @plugin.model_name.human)  
    else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end

private


end
