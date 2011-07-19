class PluginReviewsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin
 before_filter :get_group_permissions_for_plugin # get permissions for this plugin  
 before_filter :check_item_view_permissions, :only => [:show] # can user view item?
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user 
 before_filter :can_group_read_plugin, :only => [:show]
 before_filter :can_group_create_plugin, :only => [:create, :new]
 before_filter :can_group_update_plugin, :only => [:update, :edit] 
 before_filter :can_group_delete_plugin, :only => [:delete]  
 before_filter :uses_tiny_mce, :only => [:new, :edit, :create, :update]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.

 include ActionView::Helpers::TextHelper # for truncate, etc.
 
  def create   
    @item = Item.find(params[:id])
    @review = PluginReview.new
    @review.review_score = params[:review][:review_score]
    @review.review = sanitize(params[:review][:review])
    @review.user_id = @logged_in_user.id
    @review.item_id = @item.id      
    
    #if @item.is_viewable_for_user?(@logged_in_user) && ( && @logged_in_user.id == @item.user_id) || !@plugin.get_setting_bool("only_creator_can_review") || @logged_in_user.is_admin?)
     @review.is_approved = "1" if !@group_permissions_for_plugin.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin       
     if @review.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human,  :name => truncate(@review.review, :length => 10)))                                       
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] += " " +  t("notice.user_thanks", :name => @review.user.first_name)
      redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
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
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end

  def update
    @review = PluginReview.find(params[:review_id])
    @review_user = User.find(@review.user_id)
    @review.review_score = params[:review][:review_score]
    @review.review = sanitize(params[:review][:review])     
    if @review.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_save", :item => @plugin.model_name.human,  :name => truncate(@review.review, :length => 10)))                                       
      flash[:success] =  t("notice.item_save_success", :item => @plugin.model_name.human)
    else # fail saved 
      flash[:failure] =  t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
    render :action => "edit"
  end
 
 
  def change_approval
    @review = PluginReview.find(params[:review_id])    
    if  @review.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.model_name.human,  :name => "#{@review.user.username} - " + truncate(@review.review, :length => 10))
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @plugin.model_name.human,  :name => "#{@review.user.username} - " + truncate(@review.review, :length =>  10))
    end
    
    if @review.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @plugin.model_name.human)  
    else
      flash[:failure] =  t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end 
  
  def new 
    @review = PluginReview.new(:user => @logged_in_user)  
  end
 
  def edit
    @review = PluginReview.find(params[:review_id])   
  end 
 
  def vote
    @review = PluginReview.find(params[:review_id])    
    @vote = PluginReviewVote.new(:plugin_review_id => @review.id, :user_id => @logged_in_user.id)
    if params[:direction] == "up"
      @vote.score = 1 # vote score 
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_voted_for", :item => @plugin.model_name.human, :name => "#{@review.user.username} - " + truncate(@review.review, :length =>  10)))              
    elsif params[:direction] == "down"
      @vote.score = -1 # vote score 
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_voted_against", :item => @plugin.model_name.human, :name => "#{@review.user.username} - " + truncate(@review.review, :length => 10)))      
    end
    if @vote.save && @review.update_attribute(:vote_score, @review.vote_score + @vote.score)  # save record of vote and increment/decrement review's score
      flash[:success] = t("notice.user_thanks_for_voting", :name => @vote.user.first_name)             
    else # save failed 
      flash[:failure] = t("notice.item_save_failure", :item => PluginReviewVote.model_name.human)
    end
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other)               
  end                    


  def show  
    @review = PluginReview.find(params[:review_id])
    @setting[:meta_title] << @item.description     
    @setting[:meta_title] << @item.name 
    @setting[:meta_title] << [PluginReview.model_name.human, t("single.from").downcase, @review.user.username].join(" ")
  end
end
