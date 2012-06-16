class CategoriesController < ApplicationController
  before_filter :authenticate_admin # make sure logged in user is an admin   
  before_filter :enable_admin_menu
    
  def index 
    @setting[:meta_title] << Category.model_name.human(:count => :other)
    @categories = Category.root
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
    @category = Category.find(params[:id])        
    if @category.update_attributes(params[:category])
      log(:target => @category,  :log_type => "update")
      flash[:success] = t("notice.save_success")
      redirect_to :action => "index"
    else
      flash[:failure] = t("notice.save_failure")
      render :edit
    end
  end
  
  def create
    @category = Category.new(params[:category])
    #raise "#{@category.inspect} #{params[:category].inspect}"
    if @category.save
      log(:target => @category,  :log_type => "create")
      flash[:success] = t("notice.item_create_success", :item => Category.model_name.human)
      redirect_to :action => "index"      
     else
      flash[:failure] = t("notice.item_create_failure", :item => Category.model_name.human)
      render :new      
    end
  end
 
  def delete
    @category = Category.find(params[:id])    
    if @category.destroy
      log(:target => @category,  :log_type => "destroy")
      flash[:success] = t("notice.item_delete_success", :item => Category.model_name.human)
     else
      flash[:failure] = t("notice.item_delete_failure", :item => Category.model_name.human)
    end
    redirect_to :action => "index"
  end

end
