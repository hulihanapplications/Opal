class AdminController < ApplicationController 
 before_filter :authenticate_admin
 before_filter :enable_admin_menu # show admin menu


 def index
    @latest_logs = Log.find(:all, :limit => 5)
 end  

 def env
 end

private


 

end
	

