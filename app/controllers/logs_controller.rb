class LogsController < ApplicationController
  before_filter :authenticate_user # make sure a user is logged in   
  before_filter :authenticate_admin, :except => [:for_item, :for_me]  # make sure logged in user is an admin   
  before_filter :enable_admin_menu, :except => [:for_item, :for_me]
  
  before_filter :enable_user_menu, :only => [:for_me]

  before_filter :find_item, :only => [:for_item]
  before_filter :check_item_edit_permissions, :only => [:for_item]
  
  
  def index 
    @setting[:meta_title] = Log.human_name + " - " + t("section.title.admin").capitalize + " - " + @setting[:meta_title]
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
      flash[:success] = t("notice.object_save_success", :object => Log.human_name)
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log =>  t("log.object_save", :object => Log.human_name, :name => log.id))
     else
      flash[:failure] = t("notice.object_save_failure", :object => Log.human_name)
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
      flash[:success] = t("notice.object_create_success", :object => Log.human_name)
      Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log =>  t("log.object_create", :object => Log.human_name, :name => log.id))        
     else
      flash[:failure] = t("notice.object_create_failure", :object => Log.human_name)           
    end
    redirect_to :action => "index"
  end
 
  def delete # deletes feature 
    log = Log.find(params[:id])    
    if log.destroy
      flash[:success] = t("notice.object_delete_success", :object => Log.human_name)
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log =>  t("log.object_delete", :object => Log.human_name, :name => log.id))                    
    else
      flash[:failure] = t("notice.object_delete_failure", :object => Log.human_name)    
    end
    redirect_to :action => "index"
  end
  

end
