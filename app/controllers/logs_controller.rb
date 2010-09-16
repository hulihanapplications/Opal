class LogsController < ApplicationController
  before_filter :authenticate_user # make sure a user is logged in   
  before_filter :authenticate_admin, :except => [:for_item, :for_me]  # make sure logged in user is an admin   
  before_filter :enable_admin_menu, :except => [:for_item, :for_me]
  
  before_filter :enable_user_menu, :only => [:for_me]

  before_filter :find_item, :only => [:for_item]
  before_filter :check_item_edit_permissions, :only => [:for_item]
  
  
  def index 
    @setting[:meta_title] = "Logs - Admin - "+ @setting[:meta_title]    
    @logs = Log.paginate :page => params[:page], :per_page => 25
  end
  
  def for_me # for the logged in user.
    @logs = Log.paginate :page => params[:page], :per_page => 25, :conditions => Log.get_search_conditions(:user => @logged_in_user)
  end
  
  def for_item # for a particular item
    @logs = Log.paginate :page => params[:page], :per_page => 25, :conditions => Log.get_search_conditions(:item => @item)
    @setting[:show_item_nav_links] = true # show nav links          
  end
  
  def for_user # for a particular user
    @user = User.find(params[:id])
    @logs = Log.paginate :page => params[:page], :per_page => 25, :conditions => Log.get_search_conditions(:user => @user)
  end  
  
  def edit
   if params[:id] 
     @log = Log.find(params[:id])
   end     
  end
  
  def new
   if params[:id] 
     @parent_log = Log.find(params[:id])
   end 
   @log = Log.new
  end
  
  def update
    log = Log.find(params[:id])    
    if log.update_attributes(params[:log])
      flash[:notice] = "<div class=\"flash_success\">Log: <b>#{log.name}</b> updated!</div><br>"
      logger.info("Log Updated: (#{log.name})(#{log.id}) by #{@logged_in_user.username}")                  
     else
      flash[:notice] = "<div class=\"flash_failure\">Log: <b>#{log.name}</b> update failed!</div><br>"
    end
    redirect_to :action => "index"
  end
  
  def create # creates a new Feature, not a Feature Value
    #log = Log.find(params[:id])   
    log = Log.new(params[:log])
    if params[:parent_id]
      log.log_id = params[:parent_id]
    else 
      log.log_id = 0
    end
    
    if log.save
      flash[:notice] = "<div class=\"flash_success\">New Log: <b>#{log.name}</b>  created!</div><br>"
      logger.info("Log Created: (#{log.name})(#{log.id}) by #{@logged_in_user.username}")            
     else
      flash[:notice] = "<div class=\"flash_failure\">New Log creation failed! Here's why:<br><br>"
       log.errors.each do |key,value|
        flash[:notice] << "<b>#{key}</b>...#{value}</font><br>" #print out any errors!
       end
      flash[:notice] << "</div>"
      
      
    end
    redirect_to :action => "index"
  end
 
  def delete # deletes feature 
    log = Log.find(params[:id])    
    if log.destroy
      flash[:notice] = "<div class=\"flash_success\">Log: <b>#{log.name}</b> deleted!</div><br>"
      logger.info("Log Deleted: (#{log.name})(#{log.id}) by #{@logged_in_user.username}")                  
     else
      flash[:notice] = "<div class=\"flash_failure\">Log: <b>#{log.name}</b> deletion failed!</div><br>"
    end
    redirect_to :action => "index"
  end
  

end
