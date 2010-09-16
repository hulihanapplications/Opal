# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers

  helper "application" # include main application helper

  before_filter :load_settings, :set_user # load global settings and set logged in user

  # Load Layout
    if ActiveRecord::Base.connection.tables.include?('settings') # check if settings table exists
     theme = Setting.get_setting("theme") # get the theme name 
     layout_location = File.join(RAILS_ROOT, "public", "themes", theme, "layouts", "application.html.erb")
     if !File.exists?(layout_location) # if the layout file isn't present, use default layout. File.exists? requires absolute path.
       layout_location = File.join("layouts", "application.html.erb") # Use the default layout, keep the global theme as it is.
     end
    else # if theme isn't set, use default theme
     layout_location = File.join("layouts", "application.html.erb") # Use the default layout, keep the global theme as it is.
    end 
 
    layout layout_location # Load the theme erb layout
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  #:secret => '271565d54852d3da3a489c27f69a31b1'
  
  def print_errors(some_object_or_hash) # print out errors in a pretty format, takes a Object or plain Hash
     msg = ""
     if some_object_or_hash.class == Hash # load in errors from hash
       errors = some_object_or_hash
     else # load in errors from object
       errors = some_object_or_hash.errors
     end
     errors.each do |key,value|
       msg << "<b>#{key}</b>...#{value}<br>" #print out any errors!
     end
     return msg
  end


  def load_settings
    @setting = Setting.global_settings 
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
            flash[:notice] = "<div class=\"flash_failure\">Sorry, Your account has not been verified yet!</div>"
            session[:user_id] = nil # log out user
            redirect_to :action => "index", :controller => "browse"
          end
         else # not verified!
           flash[:notice] = "<div class=\"flash_failure\">Your account has been disabled.</div>"
           session[:user_id] = nil # log out user
           redirect_to :action => "index", :controller => "browse"         
         end 
     else # user is not logged in, make them a guests
       @logged_in_user = User.new(:username => "Guest", :first_name => "No", :last_name => "Name")
       @logged_in_user.id = 0       
       @logged_in_user.group_id = 1 # set for public group
       
       if !Setting.get_setting_bool("allow_public_access") && (params[:action] != "login") # if public is not allowed to view the site
          authenticate_user("<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\"> You must be logged in to view this site.") # send them to login
       end
     end
    end
    
    def authenticate_user(msg = "You are not logged in!")
      if session[:user_id].nil? || @logged_in_user.id == 0 # There's definitely no user logged in
       flash[:notice] = "<div class=\"flash_failure\">#{msg}</div>"
       session[:original_uri] = request.env["REQUEST_URI"] # store original request of where they wanted to go.
       redirect_to :action => "login", :controller => "browse"
      else #there's a user logged in, but what type is he?
        # proceed 
      end
    end
    
   def authenticate_admin
    if session[:user_id].nil? || @logged_in_user.id == 0 #There's definitely no user logged in(id 0 is public user)
     flash[:notice] = "<div class=\"flash_failure\">You're not logged in or an admin! Violation logged!</div>"
     session[:original_uri] = request.env["REQUEST_URI"] # store original request of where they wanted to go.
     Log.create(:log_type => "warning", :log => "Someone at #{request.env["REMOTE_ADDR"]} attempted to access the Admin Area. Controller: #{params[:controller]} - Action: #{params[:action]}")     
     redirect_to :action => "login", :controller => "/browse"
    else #there's a user logged in, but what type is he?
     if(@logged_in_user.is_admin?) # make sure user is an admin
      # Proceed, but log and render controller
       logger.info "Admin action: user(#{@logged_in_user.username}) -- id:(#{@logged_in_user.id}) -- action:(#{params[:action]}) -- controller:(#{params[:controller]})" 
     else # a non-admin is trying to do someting
      flash[:notice] = "<div class=\"flash_failure\">You are not logged in as a admin! Attempt logged and admin notified!</div>"
      Log.create(:log_type => "warning", :log => "#{@logged_in_user.username}(#{@logged_in_user.id}) attempted to access the Admin Area. Controller: #{params[:controller]} - Action: #{params[:action]}")
      #logger.info "Regular User attempting to access admin section! action: #{params[:action]} -- user: #{@logged_in_user.username} -- id: #{@logged_in_user.id} -- action: #{params[:action]}) -- controller: #{params[:controller]}"
      
      redirect_to :action => "index", :controller => "/browse"
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
     flash[:notice] = "<div class=\"flash_failure\">I don't know what item to look for!</div>"
     redirect_to :action => "index", :controller => "user"
   end    
   
  rescue # catch any errors
     flash[:notice] = "<div class=\"flash_failure\">Item Not Found!</div>"
     redirect_to :action => "index", :controller => "user"   
  end
  
  def check_item_edit_permissions # check to see if the logged in user has permission to edit item
     if @item.is_editable_for_user?(@logged_in_user)
       @item.update_attribute(:updated_at, Time.now) # refresh item's last update time 
       #proceed
     else # they don't have rights to the item
       flash[:notice] = "<div class=\"flash_failure\">You do not have access to edit this item!</div>"
       logger.info("Failed Edit Attempt for Item: #{@item.id} -- action: #{params[:action]} -- user: #{@logged_in_user.id}")
       redirect_to :action => "index", :controller => "user"
     end
  end 

  def get_my_group_plugin_permissions # initialize group plugin permissions for the plugin that is already looked up
     @my_group_plugin_permissions = @plugin.permissions_for_group(@logged_in_user.group) 
  end    

  def sanitize(data) # sanitize data
    html_whitelist = YAML::load(File.open(RAILS_ROOT + "/config/whitelist_html.yml")) # load html whitelist from file
    #return Sanitize.clean(data, Sanitize::Config::RELAXED)
    return Sanitize.clean(data, :elements => html_whitelist["elements"], :attributes => html_whitelist["attributes"])    
  end

  def enable_sorting # convert sort url GET variables into nice hashes for use in model sort functions(which also sanitize). This is a prefilter method.
    # Set default sort variables
    params[:sort_by] ||= "Date Added"
    params[:sort_direction] ||= "desc"
    # Create Hash 
    params[:sort] = Hash.new 
    params[:sort][:by] = params[:sort_by]
    params[:sort][:direction] = params[:sort_direction]   
  end  
end
