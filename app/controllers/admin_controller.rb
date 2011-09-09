class AdminController < ApplicationController
  before_filter :authenticate_admin
  before_filter :enable_admin_menu # show admin menu
  
  def index
    @latest_logs = Log.limit(5)
  end
end

