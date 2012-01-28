class BrowseController < ApplicationController
  before_filter :enable_sorting, :only => [:index, :user] # prepare sort variables & defaults for sorting

  def index
    @categories = Category.root
    @setting[:homepage_type] = Setting.get_setting("homepage_type")
    
    if @setting[:homepage_type] == "new_items"
      @items = Item.paginate(:page => params[:page], :per_page => @setting[:items_per_page].to_i).approved.public
      @items = @items.order(Item.sort_order(params[:sort])) if params[:sort]  
    end  
  end
  
  def lost # they're lost   
  end
    
  def user
    redirect_to :action => "show", :controller => "users", :id => params[:id]
  end
  
  private  
end
