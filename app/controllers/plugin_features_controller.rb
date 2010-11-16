class PluginFeaturesController < ApplicationController
 #before_filter :authenticate_user
 before_filter :find_item, :except => [:new, :create, :delete, :index, :edit, :update, :create_option, :delete_option] # look up item 
 before_filter :find_plugin # look up plugin
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 before_filter [:authenticate_admin, :enable_admin_menu] , :only =>  [:create, :delete, :index, :new, :edit, :update, :create_option, :delete_option] # make sure logged in user is an admin  

 include ActionView::Helpers::TextHelper # for truncate, etc.



  
  def create_feature_values
   if @my_group_plugin_permissions.can_create? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # check permissions       
     flash_msg = "" 
     #for i in 0..params[:features].size  # for every feature available to add
     params[:features].each do | id, feature |
       if feature && feature[:value] != "" # if array item has something in it and at least value was filled out
         feature_value = PluginFeatureValue.new(feature)
         feature_value.user_id = @logged_in_user.id
         feature_value.item_id = @item.id
      
         # Set Approval
         feature_value.is_approved = "1" if !@my_group_plugin_permissions.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
               
         if feature_value.save
            Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => PluginFeatureValue.human_name, :name => "#{feature_value.plugin_feature.name}: #{feature_value.value}")) 
            flash[:success] = t("notice.item_create_success", :item => PluginFeatureValue.human_name + "(#{feature_value.plugin_feature.name})") + "<br>"
            flash[:success] +=  t("notice.item_needs_approval", :item => @plugin.human_name) + "<br>"  if !feature_value.is_approved?             
         else # fail saved 
            flash_msg += t("notice.item_create_failure", :item => @plugin.human_name)
         end 
       end 
     end
    flash[:notice] = flash_msg 
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")        
   end     
    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end

  def update_feature_value
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?    
     @feature_value = PluginFeatureValue.find(params[:feature_value_id])
     @feature = PluginFeature.find(@feature_value.plugin_feature_id)
     log_msg = t("log.item_save", :item => PluginFeatureValue.human_name, :name => "#{@feature_value.plugin_feature.name}: #{@feature_value.value}")
     if @feature_value.update_attributes(:value => params[:feature_value][:value], :url => params[:feature_value][:url])
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)        
      flash[:success] = t("notice.item_save_success", :item => @plugin.human_name)
     else # fail saved 
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")       
   end    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end
 
  def delete_feature_value
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?       
     @feature_value = PluginFeatureValue.find(params[:feature_value_id])
     if @feature_value.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log_type => "new", :log => t("log.item_delete", :item => PluginFeatureValue.human_name, :name => "#{@feature_value.plugin_feature.name}: #{@feature_value.value}")) 
      flash[:success] = t("notice.item_delete_success", :item => @plugin.human_name)
     else # fail saved 
         flash[:failure] = t("notice.item_delete_failure", :item => @plugin.human_name)
     end
   else # Improper Permissions  
        flash[:failure] = t("notice.invalid_permissions")        
   end      
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end

 def change_approval
    @feature_value = PluginFeatureValue.find(params[:feature_value_id])    
    if  @feature_value.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg =  t("log.item_unapprove", :item => PluginFeatureValue.human_name,  :name => "#{@feature_value.plugin_feature.name}: #{@feature_value.value}") 
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => PluginFeatureValue.human_name, :name => "#{@feature_value.plugin_feature.name}: #{@feature_value.value}") 
    end
    
    if @feature_value.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_approve_success", :item => @plugin.human_name) 
    else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.human_name) 
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize 
  end 
 
  # Admin Only Methods 
  def create # creates a new Feature, not a Feature Value
    @feature = PluginFeature.new(params[:feature])    
    if !params[:feature][:icon_url].nil?  && params[:feature][:icon_url] != ""
      @feature.icon_url = params[:feature][:icon_url]
    end
    
    if @feature.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("log.item_create", :item => PluginFeatureValue.human_name, :name => "#{@feature.name}")) 
      flash[:success] = t("notice.item_create_success", :item => @plugin.human_name)
     else
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.human_name)
    end
    
    redirect_to :action => "index", :controller => "plugin_features"  
  end
 
  def delete # deletes feature 
    @feature = PluginFeature.find(params[:id])
    if @feature.destroy
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => PluginFeatureValue.human_name, :name => "#{@feature.name}"))       
      flash[:success] = t("notice.item_delete_success", :item => @plugin.human_name)
     else
      flash[:failure] = t("notice.item_delete_failure", :item => @plugin.human_name)
    end
    
    redirect_to :action => "index", :controller => "plugin_features"  
  end 

 def edit
   @feature = PluginFeature.find(params[:id])
 end
 
 def update
    @feature = PluginFeature.find(params[:id])
    if @feature.update_attributes(params[:feature])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => PluginFeatureValue.human_name, :name => "#{@feature.name}"))       
      flash[:success] = t("notice.item_save_success", :item => @plugin.human_name)
     else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.human_name)
  end
  
  redirect_to :action => "edit", :controller => "plugin_features", :id => @feature.id
 end
 
  def create_option # creates a new Feature value option
    @option = PluginFeatureValueOption.new(params[:option])
    @option.plugin_feature_id = params[:id]
    
    if @option.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("log.item_create", :item => PluginFeatureOption.human_name, :name => "#{@option.value}")) 
      flash[:success] = t("notice.item_create_success", :item => @plugin.human_name)
     else
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.human_name)
    end
    
    redirect_to :action => "edit", :controller => "plugin_features", :id => @option.plugin_feature_id
  end
 
  def delete_option # deletes feature value option 
    @option = PluginFeatureValueOption.find(params[:id])
    if @option.destroy
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => PluginFeatureOption.human_name, :name => "#{@option.value}")) 
      flash[:success] = t("notice.item_delete_success", :item => @plugin.human_name)
     else
      flash[:failure] = t("notice.item_delete_failure", :item => @plugin.human_name)
    end
    
    redirect_to :action => "edit", :controller => "plugin_features", :id => @option.plugin_feature_id
  end 
 
  def update_values
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?    # check plugin permissions    
    feature_errors = PluginFeature.check(:features => params[:features], :item => @item) # check if required features are present
    if feature_errors.size == 0 # make sure there's not required feature errors
      # Update Feature Valuess
      approve = (!@my_group_plugin_permissions.requires_approval?  || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?) # check if these new values will be auto-approved 
      num_of_features_updated = PluginFeature.create_values_for_item(:item => @item, :features => params[:features], :user => @logged_in_user, :delete_existing => true, :approve => approve)  
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_save", :item => @plugin.human_name, :name => "#{pluralize(num_of_features_updated, @plugin.human_name)}" ))                    
      if approve
        flash[:success] = t("notice.item_save_success", :item => @plugin.human_name)
      else 
        flash[:success] = t("notice.item_needs_approval", :item => @plugin.human_name)        
      end 
    else # failed adding required features
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.human_name)          
    end  
    redirect_to :action => "edit_values" , :id => @item    
   else # Improper Permissions  
    flash[:failure] = t("notice.invalid_permissions")    
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.human_name.pluralize     
   end         
  end
end
