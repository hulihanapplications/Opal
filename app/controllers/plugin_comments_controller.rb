class PluginCommentsController < ApplicationController
 # before_filter :authenticate_user # check if user is logged in and not a public user  
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up plugin   
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin
 before_filter :check_item_view_permissions # can user view item?   
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 before_filter :can_group_create_plugin, :only => [:create]
 before_filter :can_group_delete_plugin, :only => [:delete]   
 
 include ActionView::Helpers::TextHelper # for truncate, etc.
    
 def create # this is the only create action that doesn't require that the item is editable by the user
   if simple_captcha_valid?
     @item = Item.find(params[:id])
     @comment = PluginComment.new(params[:comment])
     if !@logged_in_user.anonymous? # if the user is not anonymous
       @comment.user_id = @logged_in_user.id # set comment user id
     else # a visitor is leaving the comment.
     end 
     
     # Set Approval
     @comment.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
     
     @comment.item_id = @item.id
     if @comment.save
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => truncate(@comment.comment, :length => 10)))  if !@logged_in_user.anonymous?
      Log.create(:item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @plugin.model_name.human, :name => "#{request.env["REMOTE_ADDR"]}: " + truncate(@comment.comment, :length => 10))) if @logged_in_user.anonymous?
      
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      flash[:success] += t("notice.item_needs_approval", :item => @plugin.model_name.human) if !@comment.is_approved?
     else # fail saved 
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
     end
   else # captcha failed'
     flash[:failure] = t("notice.invalid_captcha") 
   end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
 end 
 
 def delete
   @comment = PluginComment.find(params[:comment_id])
   if @comment.destroy
     Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @plugin.model_name.human, :name => truncate(@comment.comment, :length => 10)) ) 
     flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)     
   else # fail saved 
     flash[:failure] = t("notice.item_delete_failure", :item => @plugin.model_name.human)        
   end      
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
 end
 
 def change_approval
    @comment = PluginComment.find(params[:comment_id])    
    if @comment.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = t("log.item_unapprove", :item => @plugin.model_name.human, :name => "#{@comment.user.username} - " + truncate(@comment.comment, :length => 10)) if @comment.user_id
      log_msg = t("log.item_unapprove", :item => @plugin.model_name.human, :name => "#{@comment.anonymous_name} - " + truncate(@comment.comment, :length => 10))  if @comment.anonymous_name       
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => @plugin.model_name.human, :name => "#{@comment.user.username} - " + truncate(@comment.comment, :length => 10)) if @comment.user_id
      log_msg = t("log.item_approve", :item => @plugin.model_name.human, :name => "#{@comment.anonymous_name} - " + truncate(@comment.comment, :length => 10))  if @comment.anonymous_name             
    end
    
    if @comment.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @plugin.model_name.human)  
    else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
 end
end
