class PluginFilesController < PluginController 
  before_filter(:only => [:download]) {|c|  can?(@record, @logged_in_user, :view)} 

  def create
    @file = PluginFile.new(params[:plugin_file])
    @file.user_id = @logged_in_user.id
    @file.record = @record
    @file.title = params[:file_title]
     
    if @file.save
      log(:log_type => "create", :target => @file)
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@file.is_approved?
    else # fail saved 
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)       
    end 

    redirect_to record_path(@file.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
  end
  
  def delete
    @file = @record
    if @file.destroy
     log(:log_type => "destroy", :target => @file)
     flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
    else # fail saved 
     flash[:success] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
    end
    redirect_to :back
  end

  def download
    @file = @record  
    if (@plugin.get_setting_bool("login_required_for_download") && !@logged_in_user.anonymous?) || (!@plugin.get_setting_bool("login_required_for_download"))# are logins required for downloading?
      if @plugin.get_setting_bool("log_downloads") # log this download?
        log(:target => @file, :log_type => "download", :log => t("log.item_downloaded_by_user", :item => @plugin.model_name.human, :name => @file.filename)) # msg if a user is logged in
      end  
      @file.update_attribute(:downloads, @file.downloads + 1) # increment downloads
      
      if CarrierWave::Uploader::Base.storage == CarrierWave::Storage::Fog # if file is stored at a third party
        redirect_to @file.file.url
      else # send local file
        send_file @file.file.path, :filename => @file.filename
      end
    else # they must be logged in to download this file
      authenticate_user
    end 
  end

private
end
