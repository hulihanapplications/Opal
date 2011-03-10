# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
    
  helper "application" # include main application helper
  
  before_filter :load_settings, :set_user # load global settings and set logged in user
  before_filter :set_locale
  layout :layout_location # using a symbol defers layout choice until after a request is processed 
  
  include SimpleCaptcha::ControllerHelpers
    
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  #:secret => '271565d54852d3da3a489c27f69a31b1'
  
  def layout_location
    # Load Theme & Layout
    if ActiveRecord::Base.connection.tables.include?('settings') # check if settings table exists
      #theme = Setting.get_setting("theme") # get the theme name 
      theme = @setting[:theme]
      layout_location = File.join(Rails.root.to_s, "public", "themes", theme, "layouts", "application.html.erb") # set path to theme layout
      logger.info(layout_location)
      if !File.exists?(layout_location) # if the theme's layout file isn't present, use default layout. File.exists? requires absolute path.
        logger.info(layout_location)
        layout_location = File.join("layouts", "application.html.erb") # Use the default layout, keep the global theme as it is.
      end
    else # if theme isn't set, use default theme
      layout_location = File.join("layouts", "application.html.erb") # Use the default layout, keep the global theme as it is.
    end 
    
    return layout_location # Load the theme erb layout
  end  

  def set_locale # set language, local time, etc.
   if params[:locale] # set in url 
    I18n.locale = params[:locale]
   else # not set in url
    I18n.locale = @logged_in_user.locale # set to logged in user's locale
   end 
  end
    
  def load_settings
    @setting = Setting.global_settings 
    @setting[:theme] = params[:theme] if params[:theme] # preview theme if theme is specified in url
    @setting[:url] = "http://" + request.env["HTTP_HOST"] + "" # root url for host/port, taken from request
    # Get Meta Settings Manually So they're not cached(which causes nested meta information)
    @setting[:meta_title] = [@setting[:description], @setting[:title]]
    @setting[:meta_description] = [@setting[:description]]
  end
  
  def reload_settings # reload global settings
    Setting.global_settings = Setting.get_global_settings 
  end  

  def reload_plugins # reload cached plugins
    Plugin.plugins = Plugin.all_to_hash 
  end    
  
  # Authentication Functions
  def set_user # If user isn't logged in, log them in as Guest. Otherwise, check their account for any problems
    if session[:user_id] && session[:user_id] != 0 # if a session is already created, reset the logged in user.
      @logged_in_user = User.find(session[:user_id]) # retrieve the fresh user from DB, in case any changes are made on the db side that are different from visitor's session.
      
      # Check if User Account is Okay.
      if @logged_in_user.is_enabled? 
        if @logged_in_user.is_verified?
          # Everything Ok, proceed.
        else # not verified!
          flash[:failure] = t("notice.account_not_verified")
          session[:user_id] = nil # log out user
          redirect_to :action => "index", :controller => "browse"
        end
      else # not verified!
        flash[:failure] = t("notice.account_disabled")
        session[:user_id] = nil # log out user
        redirect_to :action => "index", :controller => "browse"         
      end 
    else # user is not logged in, make them a guests
      @logged_in_user = User.new(:username => "Guest", :first_name => "No", :last_name => "Name")
      @logged_in_user.id = 0       
      @logged_in_user.group_id = 1 # set for public group
      @logged_in_user.locale = Setting.get_setting("locale") # set system default locale
      if !Setting.get_setting_bool("allow_public_access") && (params[:action] != "login") # if public is not allowed to view the site
        authenticate_user#("<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\"> You must be logged in to view this site.") # send them to login
      end
    end
  end
  
  def authenticate_user(msg = t("notice.user_not_logged_in"))
    if session[:user_id].nil? || @logged_in_user.anonymous? # There's definitely no user logged in
      flash[:failure] = "#{msg}"
      session[:original_uri] = request.env["REQUEST_URI"] # store original request of where they wanted to go.
      redirect_to :action => "login", :controller => "browse"
    else #there's a user logged in, but what type is he?
      # proceed 
    end
  end
  
  def authenticate_admin
    if session[:user_id].nil? || @logged_in_user.anonymous? #There's definitely no user logged in(id 0 is public user)
      flash[:failure] = t("notice.failed_admin_access_attempt")
      session[:original_uri] = request.env["REQUEST_URI"] # store original request of where they wanted to go.
      Log.create(:log_type => "warning", :log => t("log.failed_admin_access_attempt_visitor", :ip => request.env["REMOTE_ADDR"], :controller => params[:controller], :action => params[:action]))     
      redirect_to :action => "login", :controller => "browse"
    else #there's a user logged in, but what type is he?
      if(@logged_in_user.is_admin?) # make sure user is an admin
        # Proceed
        @setting[:meta_title] << t("section.title.admin")
      else # a non-admin is trying to do someting
        flash[:failure] = t("notice.failed_admin_access_attempt")
        Log.create(:log_type => "warning", :log => t("log.failed_admin_access_attempt_user", :username => @logged_in_user.username, :id => @logged_in_user.id, :controller => params[:controller], :action => params[:action]))        
        redirect_to :action => "index", :controller => "browse"
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
    else # no item id passed in
      flash[:failure] = t("notice.item_not_found", :item => @setting[:item_name])
      redirect_to :action => "index", :controller => "user"
    end        
  rescue # catch any errors
    flash[:failure] = t("notice.item_not_found", :item => @setting[:item_name])
    redirect_to :action => "index", :controller => "user"   
  end
  
  def find_plugin(options = {}) # look up a plugin 
    # Look up plugin based on controller name, ie: PluginCommentsController
    plugin_name = self.controller_name.split("_") # "PluginComments" -> "plugin_comments" -> ["plugin", "comments"]
    plugin_name = plugin_name[1].capitalize.singularize # get the second part of the controller name
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
    flash[:failure] = t("notice.item_not_found", :item => @plugin.model_name.human(:count => :other))
  end
  
  def check_item_view_permissions # can user view this item?
    if @item.is_viewable_for_user?(@logged_in_user)
        # proceed
    else 
     flash[:failure] = t("notice.not_visible")   
     redirect_to :action => "index", :category => "browse"      
    end
  end
  
  def check_item_edit_permissions # check to see if the logged in user has permission to edit item
    if @item.is_editable_for_user?(@logged_in_user)
      @item.update_attribute(:updated_at, Time.now) # refresh item's last update time 
      #proceed
    else # they don't have rights to the item
      flash[:failure] = t("notice.invalid_permissions")
      redirect_to :action => "index", :controller => "user"
    end
  end 
  
  def get_my_group_plugin_permissions # initialize group plugin permissions for the plugin that is already looked up
    @my_group_plugin_permissions = @plugin.permissions_for_group(@logged_in_user.group) 
  end    
  
  def sanitize(data) # sanitize data
    html_whitelist = YAML::load(File.open(Rails.root.to_s + "/config/whitelist_html.yml")) # load html whitelist from file
    #return Sanitize.clean(data, Sanitize::Config::RELAXED)
    return Sanitize.clean(data, :elements => html_whitelist["elements"], :attributes => html_whitelist["attributes"])    
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
end
