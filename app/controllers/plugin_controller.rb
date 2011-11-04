class PluginController < ApplicationController
  before_filter :find_record # look up record 
  before_filter :find_plugin, :except => [:vote, :change_approval] # look up plugin 

  before_filter(:except => [:vote, :change_approval]) {|c| can?(@record, @logged_in_user, :view)} 
  before_filter(:only => [:change_approval]){|c| can?(@record.record, @logged_in_user, :edit)}      

  before_filter(:only => [:new, :create]) {|c| can?(@plugin.plugin_class, @logged_in_user, :create, :record => @record)} 
  before_filter(:only => [:edit, :update]) {|c| can?(@record, @logged_in_user, :edit)} 
  before_filter(:only => [:delete]){|c| can?(@record, @logged_in_user, :destroy)} 
   
  def vote
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
  
  def change_approval
    if @record.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @record.class.model_name.human, :name => @record.id)
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @record.class.model_name.human, :name => @record.id)
    end
    
    if @record.update_attribute(:is_approved, approval)
      log(:log_type => "update", :target => @record, :log => log_msg)
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @record.class.model_name.human)  
    else
      flash[:failure] = t("notice.item_save_failure", :item => @record.class.model_name.human)
    end
    redirect_to :back 
  end
end
