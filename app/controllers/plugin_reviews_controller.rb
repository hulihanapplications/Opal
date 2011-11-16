class PluginReviewsController < PluginController 
 before_filter(:only => [:show]) {|c|  can?(@record, @logged_in_user, :view)} 
 before_filter:uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.
 include ActionView::Helpers::TextHelper # for truncate, etc.
 
  def create   
    @review = PluginReview.new(params[:review])
    @review.user_id = @logged_in_user.id
    @review.record = @item      
    
    if @review.save
      log(:log_type => "create", :target => @review)
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] += " " +  t("notice.user_thanks", :name => @review.user.first_name)
      redirect_to record_path(@review.record, :anchor => @plugin.plugin_class.model_name.human(:count => :other))
    else # fail saved 
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
      render :action => "new"
    end               
  end
 
  def delete
    @review = @record
    @review_user = User.find(@review.user_id)
    if @review.destroy
      log(:log_type => "destroy", :target => @review)
      flash[:success] =  t("notice.item_delete_success", :item => @plugin.model_name.human)    
    else # fail saved 
      flash[:failure] =  t("notice.item_delete_failure", :item => @plugin.model_name.human)     
    end
    redirect_to :back
  end

  def update
    @review = @record
    @review_user = User.find(@review.user_id)
    @review.attributes = params[:review]    
    if @review.save
      log(:log_type => "update", :target => @review)
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
    @review = @record  
  end 

  def show  
    @review = @record
    @setting[:meta_title] << @review.record.description     
    @setting[:meta_title] << @review.record.name 
    @setting[:meta_title] << [PluginReview.model_name.human, t("single.from").downcase, @review.user.username].join(" ")
  end
end
