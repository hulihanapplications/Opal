class CategoriesController < ApplicationController
  before_filter :authenticate_admin # make sure logged in user is an admin   
  before_filter :enable_admin_menu
  
  def index 
    @setting[:meta_title] = "Categories - Admin - "+ @setting[:meta_title]
    @categories = Category.find(:all, :conditions =>["category_id = 0"], :order => "name ASC")
  end
  
  def edit
   if params[:id] 
     @category = Category.find(params[:id])
   end     
  end
  
  def new 
   @category = Category.new
   if params[:id] 
     @category.category_id = Category.find(params[:id]).id
   end   
  end
  
  def update
    category = Category.find(params[:id])    
    if params[:category][:category_id].to_i != category.id # trying to select self as parent category 
      if category.update_attributes(params[:category])
        Log.create(:user_id => @logged_in_user.id,  :log_type => "system", :log => "Updated the Category: #{category.name}(#{category.id}).")
        flash[:notice] = "<div class=\"flash_success\">Category: <b>#{category.name}</b> updated!</div>"
        logger.info("Category Updated: (#{category.name})(#{category.id}) by #{@logged_in_user.username}")                  
      else
        flash[:notice] = "<div class=\"flash_failure\">Category: <b>#{category.name}</b> update failed!</div>"
      end
    else
      flash[:notice] = "<div class=\"flash_failure\">A category can't be a subcategory of itself!</div>"
    end      
    redirect_to :action => "index"
  end
  
  def create # creates a new Feature, not a Feature Value
    #category = Category.find(params[:id])   
    category = Category.new(params[:category])
    
    if category.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => "Created the Category: #{category.name}.")
      flash[:notice] = "<div class=\"flash_success\">New Category: <b>#{category.name}</b>  created!</div>"
     else
      flash[:notice] = "<div class=\"flash_failure\">New Category creation failed! Here's why:<br><br>"
       category.errors.each do |key,value|
        flash[:notice] << "<b>#{key}</b>...#{value}</font><br>" #print out any errors!
       end
      flash[:notice] << "</div>"
      
      
    end
    redirect_to :action => "index"
  end
 
  def delete # deletes feature 
    category = Category.find(params[:id])    
    if category.destroy
      Log.create(:user_id => @logged_in_user.id,  :log_type => "system", :log => "Deleted the Category: #{category.name}(#{category.id}).")
      flash[:notice] = "<div class=\"flash_success\">Category: <b>#{category.name}</b> deleted!</div>"
      logger.info("Category Deleted: (#{category.name})(#{category.id}) by #{@logged_in_user.username}")                  
     else
      flash[:notice] = "<div class=\"flash_failure\">Category: <b>#{category.name}</b> deletion failed!</div>"
    end
    redirect_to :action => "index"
  end

end
