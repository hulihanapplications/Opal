class PluginController < ApplicationController
  before_filter :find_item # look up item 
  before_filter :find_plugin # look up item  
  before_filter :get_group_permissions_for_plugin # get permissions for this plugin
  before_filter :find_record, :only => [:vote, :change_approval]  # 
  before_filter :check_item_view_permissions, :except => [:vote] # can user view item? 
  before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
  before_filter :can_group_read_plugin
  before_filter :can_group_create_plugin, :only => [:new, :create, :vote]
  before_filter :can_group_update_plugin, :only => [:edit, :update] 
  before_filter :can_group_delete_plugin, :only => [:delete]  
  
  def find_record # look up record
  	klass = params[:record_type].camelize.constantize
  	@record = klass.find(params[:record_id])
  	if @record.nil? 
        flash[:failure] = t("notice.item_not_found", :item => klass.model_name.human)
		redirect_to :back
  	end	
  end
   
  def vote
     if @record    	
       if @logged_in_user.voted?(@record) # have they already voted?
         notice = @logged_in_user.up_voted?(@record) ? "unvoted_up" : "unvoted_down"
         @logged_in_user.unvote(@record)
       else # they haven't voted yet
         if params[:direction] == "up" 
            notice = "voted_up" if @logged_in_user.up_vote(@record)         
         else
           notice = "voted_down" if @logged_in_user.down_vote(@record)
         end        
       end 
      respond_to do |format|     
      	format.html {
          render :json => {:votes => @record.votes, :direction => params[:direction], :notice => notice} if request.xhr? # if ajax request, just load partial instead of full layout
        }
        format.xml  { render :xml => data }  
      end
    end
  end
  
  def change_approval
    if @record.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.model_name.human, :name => @record.id)
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @plugin.model_name.human, :name => @record.id)
    end
    
    if @record.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @plugin.model_name.human)  
    else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @record.class.model_name.human(:count => :other) 
  end
end
