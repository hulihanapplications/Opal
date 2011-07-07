class PluginController < ApplicationController
  before_filter :find_item # look up item 
  before_filter :find_plugin # look up item  
  before_filter :get_group_permissions_for_plugin # get permissions for this plugin
  before_filter :check_item_view_permissions, :except => [:vote] # can user view item? 
  before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
  before_filter :can_group_create_plugin, :only => [:new, :create, :vote]
  before_filter :can_group_update_plugin, :only => [:edit, :update] 
  before_filter :can_group_delete_plugin, :only => [:delete]  
   
  def vote
     record = params[:record_type].camelize.constantize.find(params[:record_id])
     if record    	
       if @logged_in_user.voted?(record) # have they already voted?
         notice = @logged_in_user.up_voted?(record) ? "unvoted_up" : "unvoted_down"
         @logged_in_user.unvote(record)
       else # they haven't voted yet
         if params[:direction] == "up" 
            notice = "voted_up" if @logged_in_user.up_vote(record)         
         else
           notice = "voted_down" if @logged_in_user.down_vote(record)
         end        
       end 
      respond_to do |format|     
      	format.html {
          render :json => {:votes => record.votes, :direction => params[:direction], :notice => notice} if request.xhr? # if ajax request, just load partial instead of full layout
        }
        format.xml  { render :xml => data }  
      end
    end
  end
end
