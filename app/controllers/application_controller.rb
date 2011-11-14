# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base    
  helper :all
  before_filter :load_settings, :set_user # load global settings and set logged in user
  before_filter :set_locale, :check_public_access
  #before_filter :detect_mobile
  before_filter :detect_flash
  layout :layout_location # using a symbol defers layout choice until after a request is processed 
  
    
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  #:secret => '271565d54852d3da3a489c27f69a31b1'

  helper_method :current_user  
 
	
  def layout_location # this will eventually be deprecated, in favor of prepend_view_path
    # Load Theme & Layout
    mobile_mode? ? layout_filename = "application.mobile.erb" : layout_filename = "application.html.erb"
    if ActiveRecord::Base.connection.tables.include?('settings') # check if settings table exists
      #theme = Setting.get_setting("theme") # get the theme name 
      theme = @setting[:theme]
      layout_location = File.join(Rails.root.to_s, "public", "themes", theme, "layouts", layout_filename) # set path to theme layout
      logger.info(layout_location)
      if !File.exists?(layout_location) # if the theme's layout file isn't present, use default layout. File.exists? requires absolute path.
        logger.info(layout_location)
        layout_location = File.join("layouts", layout_filename) # Use the default layout, keep the global theme as it is.
      end
    else # if theme isn't set, use default theme
      layout_location = File.join("layouts", layout_filename) # Use the default layout, keep the global theme as it is.
    end 
    
    return layout_location # Load the theme erb layout
  end   

  def set_locale # set language, local time, etc.
   if params[:locale] # set in url 
    I18n.locale = params[:locale]
   else # not set in url
    I18n.locale = @logged_in_user.locale.blank? ? Setting.global_settings[:locale] : @logged_in_user.locale # set to logged in user's locale
   end 
  end
    
  def load_settings
    @setting = Setting.global_settings 
    @setting[:theme] = params[:theme] if params[:theme] # preview theme if theme is specified in url
    prepend_view_path(File.join(@setting[:themes_dir], @setting[:theme],  "app", "views")) if @setting[:theme] && @setting[:themes_dir] # add the curent theme's view path to view paths to load
    @setting[:url] = request.protocol + request.host_with_port # root url for host/port, taken from request
    # Get Meta Settings Manually So they're not cached(which causes nested meta information)
    @setting[:meta_title] = Array.new
    @setting[:meta_title] << @setting[:description] if !@setting[:description].blank?
    @setting[:meta_title] << @setting[:title] if !@setting[:title].blank?
    @setting[:meta_description] = [@setting[:description]]
  end
  
  def reload_settings # reload global settings
    Setting.reload 
  end  

  def reload_plugins # reload cached plugins
    Plugin.plugins = Plugin.all_to_hash 
  end    
  
  # Authentication Functions
  def set_user
    @logged_in_user = current_user ? current_user : User.anonymous
  end
    
  def check_public_access # check if public access is allowed to the app
    authenticate_user if !@setting[:allow_public_access] # send user to login if public is not allowed to view the site
  end
  
  def authenticate_user(msg = t("notice.user_not_logged_in"))
    if @logged_in_user.anonymous? # There's definitely no user logged in
      flash[:failure] = "#{msg}"
      redirect_to login_url(:redirect_to => destination) # store original request of where they wanted to go.
    else #there's a user logged in, but what type is he?
      if @logged_in_user.is_enabled? # Check if account is in good standing
        redirect_to verification_required_path if !@logged_in_user.is_verified? && params[:action] != "verification_required"        
      else # not verified!
        flash[:failure] = t("notice.account_disabled")
        UserSession.find.destroy # log out
        redirect_to root_url     
      end 
    end
  end
  
  def authenticate_admin
    if @logged_in_user.anonymous? #There's definitely no user logged in(id 0 is public user)
      flash[:failure] = t("notice.failed_admin_access_attempt") 
      log(:log_type => "warning", :log => I18n.t("log.failed_admin_access_attempt_visitor", :ip => request.env["REMOTE_ADDR"], :controller => params[:controller], :action => params[:action]))     
      redirect_to login_url(:redirect_to => destination) # store original request of where they wanted to go.
    else #there's a user logged in, but what type is he?
      if(@logged_in_user.is_admin?) # make sure user is an admin
        # Proceed
        @setting[:meta_title] << t("section.title.admin")
      else # a non-admin is trying to do someting
        flash[:failure] = t("notice.failed_admin_access_attempt")
        log(:log_type => "warning", :log => I18n.t("log.failed_admin_access_attempt_user", :username => @logged_in_user.username, :id => @logged_in_user.id, :controller => params[:controller], :action => params[:action]))        
        redirect_to root_url
      end
    end
  end
  
  def get_setting(name) # get a setting from the database
    setting = Setting.find(:first, :conditions => ["name = ?", name], :limit => 1 )
    return setting.value
  rescue # ActiveRecord not found
    return false   
  end
  
  def get_setting_bool(name) # get a setting from the database return true or false depending on "1" or "0"
    setting = Setting.find(:first, :conditions => ["name = ?", name], :limit => 1 )
    if setting.value == "1"
      return true
    else # not true
      return false
    end
  rescue # ActiveRecord not found
    return false   
  end
  
  def enable_admin_menu # render admin menu on a particular action
    @show_admin_menu = true 
  end
    
  def enable_user_menu # render user menu on a particular action
    @show_user_menu = true 
  end
  
  
  def find_item # look up an item
    if params[:id] # is an item id set?    
      @item = Item.find(params[:id])
      @record = @item if params[:record_type].blank? || params[:reocord_type] == "Item" 
    end        
  rescue # catch any errors
    flash[:failure] = t("notice.item_not_found", :item => Item.model_name.human)
    redirect_to :action => "index", :controller => "user"   
  end
  
  def find_plugin(options = {}) # look up a plugin 
    # Look up plugin based on controller name, ie: PluginCommentsController
    tmp_controller_name = self.controller_name
    plugin_name = tmp_controller_name.split("_")[1].capitalize.singularize # "PluginComments" -> "plugin_comments" -> ["plugin", "comments"]
    @plugin = Plugin.find_by_name(plugin_name)
    if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
    else # Plugin Disabled 
     flash[:failure] = t("notice.items_disabled", :items => @plugin.model_name.human(:count => :other))
     if defined?(@item) # has an item already been looked up?
      redirect_to :action => "view", :controller => "items", :id => @item.id # redirect to item page
     else
      redirect_to :back
     end  
    end
  rescue Exception => e  
    logger.info e.message
    flash[:failure] = e.message # t("notice.item_not_found", :item => plugin_name)
    redirect_to :back
  end
 
    
  def enable_sorting # convert sort url GET variables into nice hashes for use in model sort functions(which also sanitize). This is a prefilter method.
    # Set default sort variables
    params[:sort_by] ||= Item.human_attribute_name(:created_at)
    params[:sort_direction] ||= "desc"
    # Create Hash 
    params[:sort] = Hash.new 
    params[:sort][:by] = params[:sort_by]
    params[:sort][:direction] = params[:sort_direction]   
  end  
  
  def uses_tiny_mce(options = {}) # replacement for tiny_mce gem
    proc = Proc.new do |c|
      c.instance_variable_set(:@uses_tiny_mce, true)
      @uses_tiny_mce = true
    end
    proc.call(self)
  end  
  
  # find_record is a prerender filter that looks up an ActiveRecord object for use in the final action. 
  # The record object that is specified by the request will vary depending on the action that is being called. 
  #   new/create - record should be parent of the new object being created
  #   edit/update/destroy - record should be the object that will action will be performed on
  def find_record 
    if !params[:record_type].blank?
      klass = params[:record_type].camelize.constantize
      @record = klass.find(params[:record_id])
      @item = @record if @record.is_a?(Item)
    end
  end  

private  
  def sign_in(user)
    if @logged_in_user.nil? || @logged_in_user.anonymous? 
      user_session = UserSession.new(User.find_by_single_access_token(user.single_access_token))
      user_session.save
    end
  end

  def sign_in_and_redirect(user)
    sign_in(user)
    redirect_to user_home_path
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
    
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end


  def mobile_device? # are they on a mobile device?
    request.user_agent =~ /Mobile|webOS/
  end
  
  def mobile_mode? # are they viewing the website in mobile mode?
    if session[:mobile_mode]
      session[:mobile_mode] == "1"
    else
      mobile_device?
    end    
  end 
  
  helper_method :mobile_device?
  helper_method :mobile_mode?
  
  def detect_mobile
    session[:mobile_mode] = params[:mobile] if params[:mobile]        
    request.format = :mobile if mobile_mode?
  end
  
  def detect_flash
    request.format = :flash if flash_request?
  end
  
  def flash_request? # detect flash request
    return true if request.user_agent =~ /^(Adobe|Shockwave) Flash/
  end   

  # check permission/access, controller style
  def can?(target, performer, action, options = {})
    #logger.info "can? #{action} failed on #{target} by #{performer}"
    if target
      if !target.can?(performer, action, options)
        flash[:failure] = t("notice.invalid_permissions") + action.to_s + target.inspect
        respond_to do |format|     
          format.html {request.xhr? ? render(:text => flash[:failure]) : redirect_to(:back)} 
        end       
      end
    else
      flash[:failure] = t("notice.item_not_found", :item => t("single.object", :default => "Object"))      
      redirect_to :back
    end       
  end 

  # Generate Polymorphic Url for non-resources, similar to resource-based polymorphic_url  
  def record_path(record, options = {})
    url_for options.merge(:action => :view, :controller => record.class.controller_name, :id => record.id)
  end
  
  helper_method :record_path  
  
  def destination
    request.env["REQUEST_URI"]    
  end
end