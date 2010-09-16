class PluginReviewsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin
 before_filter :get_plugin_settings
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 
 uses_tiny_mce :only => [:new, :edit]  # which actions to load tiny_mce, TinyMCE Config is done in Layout.

 
 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Review"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Item Object Not enabled
      flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div>"
      redirect_to :action => "view", :controller => "items", :id => @item.id         
   end
 end
 
 def get_plugin_settings # get settings just for this plugin
   @setting[:review_type] = @plugin.get_setting("review_type")
   @setting[:score_min] = @plugin.get_setting("score_min").to_i     
   @setting[:score_max] = @plugin.get_setting("score_max").to_i   
 end 
 
 def create
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions                   
      @item = Item.find(params[:id])
      if @item.is_viewable_for_user?(@logged_in_user) && ((@plugin.get_setting_bool("only_creator_can_review") && @logged_in_user.id == @item.user_id) || !@plugin.get_setting_bool("only_creator_can_review") || @logged_in_user.is_admin?)
         @previous_reviews = PluginReview.find(:all, :conditions => ["user_id = ? and item_id = ?", @logged_in_user.id, @item.id])
         if @previous_reviews.size == 0 # they haven't added a review yet.
           @review = PluginReview.new
           @review.review_score = params[:review][:review_score]
           @review.review = sanitize(params[:review][:review])
           @review.user_id = @logged_in_user.id
           @review.item_id = @item.id
           @review.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin       
           if @review.review_score >=  @setting[:score_min] && @review.review_score <= @setting[:score_max] 
             if @review.save
              Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Added a #{@plugin.title}.")                                       
              flash[:notice] = "<div class=\"flash_success\">New #{@plugin.title} added. Thanks for your input!</div>"
              flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !@review.is_approved?                 
             else # fail saved 
              flash[:notice] = "<div class=\"flash_failure\">This #{@plugin.title} could not be added! Here's why:<br>#{print_errors(@review)}</div>"
             end
            else # score out of range
              flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} score must be between #{@setting[:score_min]} and #{@setting[:score_max]}</div>"
            end          
         else # they've already added a review.
            flash[:notice] = "<div class=\"flash_failure\">Sorry, You've already left a review for this #{@setting[:item_name]}.</div>"
         end    
      else # they're not allowed to add the review
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you're not allowed to add reviews to this #{@setting[:item_name]}.</div>"
      end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"        
   end       
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end
 
 def delete
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions               
     @review = PluginReview.find(params[:review_id])
     @review_user = User.find(@review.user_id)
     if @review.destroy
       Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted #{@plugin.title} from #{@review_user.username}(#{@review.id}).")                                       
       flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} deleted!</div>"     
     else # fail saved 
       flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} could not be deleted!</div>"     
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div>"        
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end

 def update
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions               
     @review = PluginReview.find(params[:review_id])
     @review_user = User.find(@review.user_id)
     @review.review_score = params[:review][:review_score]
     @review.review = sanitize(params[:review][:review])     
     if @review.review_score >=  @setting[:score_min] && @review.review_score <= @setting[:score_max]      
       if @review.save
         Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => "Updated #{@plugin.title} from #{@review_user.username}(#{@review.id}).")                                       
         flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} updated!</div>"     
       else # fail saved 
         flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} could not be updated!</div>"     
       end
    else # score out of range
      flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} score must be between #{@setting[:score_min]} and #{@setting[:score_max]}</div>"
      redirect_to :action => "edit"
    end    
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot update #{@plugin.title}s.</div>"        
   end  
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
 end
 
 
 def change_approval
    @review = PluginReview.find(params[:review_id])    
    if  @review.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@review.user.username}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@review.user.username}."
    end
    
    if @review.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div>"
    end
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end 
  
  def new 
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions
      @review = PluginReview.new     
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"
        redirect_to :action => "view", :controller => "items", :id => @item.id     
   end    
  end
 
  def edit
     if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?
       @review = PluginReview.find(params[:review_id])
      
     else # Improper Permissions  
          flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot update #{@plugin.title}s.</div>"
          redirect_to :action => "view", :controller => "items", :id => @item.id                 
     end    
 end 
 
 def vote
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions
      @review = PluginReview.find(params[:review_id])    
      @vote = PluginReviewVote.new(:plugin_review_id => @review.id, :user_id => @logged_in_user.id)
      if params[:direction] == "up"
        @vote.score = 1 # vote score 
        Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => "Voted for #{@review.user.username}'s #{@plugin.title}")              
      elsif params[:direction] == "down"
        @vote.score = -1 # vote score 
        Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => "Voted against #{@review.user.username}'s #{@plugin.title}")      
      end
      if @vote.save && @review.update_attribute(:vote_score, @review.vote_score + @vote.score)  # save record of vote and increment/decrement review's score
        flash[:notice] = "<div class=\"flash_success\">Thanks for voting for this #{@plugin.title}!</div>"             
      else # save failed 
        flash[:notice] = "<div class=\"flash_failure\">Your vote could not be added! Here's why:<br>#{print_errors(@vote)}</div>"
      end
   else # Improper Permissions  
      flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot vote for #{@plugin.title}s.</div>"     
  end
  redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s"               
 end                    

end
