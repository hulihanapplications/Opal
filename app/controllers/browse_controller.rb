class BrowseController < ApplicationController
  before_filter :enable_sorting, :only => [:index, :user] # prepare sort variables & defaults for sorting

  def index
    @categories = Category.find(:all, :select => "name, id", :limit => 1000, :order => "name asc")
    @setting[:homepage_type] = Setting.get_setting("homepage_type")
    
    if @setting[:homepage_type] == "new_items"
      @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => Item.sort_order(params[:sort]), :conditions => [" is_approved = '1' and is_public = '1'"]     
    end  
  end
  
  def lost # they're lost   
  end
    
  def user
    redirect_to :action => "show", :controller => "users", :id => params[:id]
  end
  
  private  
end
