class AdminController < ApplicationController 
 before_filter :authenticate_admin
 before_filter :enable_admin_menu # show admin menu


 def index
    @setting[:meta_title] = "Admin - "+ @setting[:meta_title]
    @plugins = Plugin.find(:all, :order => "order_number ASC", :conditions => ["is_enabled = '1'"])       
    @latest_logs = Log.find(:all, :limit => 10)
 end  

private


 

end
	

