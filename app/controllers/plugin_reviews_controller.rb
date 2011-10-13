class PluginReviewsController < PluginController
 before_filter :only => [:show] {|c| can?(@record.record, @logged_in_user, :view)} 
 before_filter :can_group_read_plugin, :only => [:show]
 before_filter :can_group_create_plugin, :only => [:create, :new]
 before_filter :can_group_update_plugin, :only => [:update, :edit] 
 before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.
 include ActionView::Helpers::TextHelper # for truncate, etc.
 
  def create   
    @item = Item.find(params[:id])
    @review = PluginReview.new(params[:review])
    @review.user_id = @logged_in_user.id
    @review.record = @item      
    
    if @review.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human,  :name => truncate(@review.review, :length => 10)))                                       
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] += " " +  t("notice.user_thanks", :name => @review.user.first_name)
      redirect_to :back
    else # fail saved 
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
      render :action => "new"
    end               
  end
 
  def delete
    @review = PluginReview.find(params[:review_id])
    @review_user = User.find(@review.user_id)
    if @review.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human,  :name => truncate(@review.review, :length => 10)))                                       
      flash[:success] =  t("notice.item_delete_success", :item => @plugin.model_name.human)    
    else # fail saved 
      flash[:failure] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)     
    end
    redirect_to :back
  end

  def update
    @review = PluginReview.find(params[:review_id])
    @review_user = User.find(@review.user_id)
    @review.attributes = params[:review]    
    if @review.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_save", :item => @plugin.model_name.human,  :name => truncate(@review.review, :length => 10)))                                       
      flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
    else # fail saved 
      flash[:failure] =  t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
    render :action => "edit"
  end
  
  def new 
    @review = PluginReview.new
    @review.user = @logged_in_user      
  end
 
  def edit
    @review = PluginReview.find(params[:review_id])   
  end 

  def show  
    @review = PluginReview.find(params[:review_id])
    @setting[:meta_title] << @item.description     
    @setting[:meta_title] << @item.name 
    @setting[:meta_title] << [PluginReview.model_name.human, t("single.from").downcase, @review.user.username].join(" ")
  end
end
