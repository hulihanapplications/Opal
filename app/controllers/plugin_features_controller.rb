class PluginFeaturesController < ApplicationController
  #before_filter :authenticate_user
  before_filter :find_item, :except => [:new, :create, :delete, :index, :edit, :update, :create_option, :delete_option, :options] # look up item 
  before_filter :find_plugin # look up plugin
  before_filter :get_group_permissions_for_plugin # get permissions for this plugin
  before_filter :check_item_view_permissions, :only => [:create_feature_values, :update_feature_value, :update_values, :delete_feature_values] # can user view item? 
  before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
  before_filter :authenticate_admin, :enable_admin_menu, :only =>  [:create, :delete, :index, :new, :edit, :update, :create_option, :delete_option, :options] # make sure logged in user is an admin  
  before_filter :can_group_create_plugin, :only => [:create_feature_values]
  before_filter :can_group_update_plugin, :only => [:update_feature_value, :update_values] 
  before_filter :can_group_delete_plugin, :only => [:delete_feature_value]  
  include ActionView::Helpers::TextHelper # for truncate, etc.
  
  def create_feature_values
   flash_msg = "" 
   #for i in 0..params[:features].size  # for every feature available to add
   params[:features].each do | id, feature |
     if feature && feature[:value] != "" # if array item has something in it and at least value was filled out
       feature_value = PluginFeatureValue.new(feature)
       feature_value.user_id = @logged_in_user.id
       feature_value.item_id = @item.id
    
       # Set Approval
       feature_value.is_approved = "1" if !@group_permissions_for_plugin.requires_approval? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin? # approve if not required or owner or admin 
             
       if feature_value.save
          Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => PluginFeatureValue.model_name.human, :name => "#{feature_value.plugin_feature.name}: #{feature_value.value}")) 
          flash[:success] = t("notice.item_create_success", :item => PluginFeatureValue.model_name.human + "(#{feature_value.plugin_feature.name})") + "<br>"
          flash[:success] +=  t("notice.item_needs_approval", :item => @plugin.model_name.human) + "<br>"  if !feature_value.is_approved?             
       else # fail saved 
          flash_msg += t("notice.item_create_failure", :item => @plugin.model_name.human)
       end 
     end 
   end
   flash[:notice] = flash_msg 
   
    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end

  def update_feature_value
   @plugin_feature_value = PluginFeatureValue.find(params[:feature_value_id])
   @plugin_feature = PluginFeature.find(@plugin_feature_value.plugin_feature_id)
   log_msg = t("log.item_save", :item => PluginFeatureValue.model_name.human, :name => "#{@plugin_feature_value.plugin_feature.name}: #{@plugin_feature_value.value}")
   if @plugin_feature_value.update_attributes(:value => params[:feature_value][:value], :url => params[:feature_value][:url])
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)        
    flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)
   else # fail saved 
    flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)
   end    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end
 
  def delete_feature_value
   @plugin_feature_value = PluginFeatureValue.find(params[:feature_value_id])
   if @plugin_feature_value.destroy
    Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log_type => "new", :log => t("log.item_delete", :item => PluginFeatureValue.model_name.human, :name => "#{@plugin_feature_value.plugin_feature.name}: #{@plugin_feature_value.value}")) 
    flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
   else # fail saved 
       flash[:failure] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
   end
 
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end

 def change_approval
    @plugin_feature_value = PluginFeatureValue.find(params[:feature_value_id])    
    if  @plugin_feature_value.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg =  t("log.item_unapprove", :item => PluginFeatureValue.model_name.human,  :name => "#{@plugin_feature_value.plugin_feature.name}: #{@plugin_feature_value.value}") 
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = t("log.item_approve", :item => PluginFeatureValue.model_name.human, :name => "#{@plugin_feature_value.plugin_feature.name}: #{@plugin_feature_value.value}") 
    end
    
    if @plugin_feature_value.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:success] = t("notice.item_#{"un" if approval == "0"}approve_success", :item => @plugin.model_name.human)  
    else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human) 
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => @plugin.model_name.human(:count => :other) 
  end 
 
  def new
       @plugin_feature = PluginFeature.new    
  end
  # Admin Only Methods 
  def create # creates a new Feature, not a Feature Value
    @plugin_feature = PluginFeature.new(params[:plugin_feature])    
    if !params[:plugin_feature][:icon_url].nil?  && params[:plugin_feature][:icon_url] != ""
      @plugin_feature.icon_url = params[:plugin_feature][:icon_url]
    end
    
    if @plugin_feature.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("log.item_create", :item => PluginFeatureValue.model_name.human, :name => "#{@plugin_feature.name}")) 
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      redirect_to :action => "index", :controller => "plugin_features"  
     else
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
      render :action => "new"
    end
    
  end
 
  def delete # deletes feature 
    @plugin_feature = PluginFeature.find(params[:id])
    if @plugin_feature.destroy
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => PluginFeatureValue.model_name.human, :name => "#{@plugin_feature.name}"))       
      flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
     else
      flash[:failure] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
    end
    
    redirect_to :action => "index", :controller => "plugin_features"  
  end 

 def edit
   @plugin_feature = PluginFeature.find(params[:id])
   @plugin_feature_value_option = PluginFeatureValueOption.new(:plugin_feature_id => @plugin_feature.id)
 end
 
 def update
    @plugin_feature = PluginFeature.find(params[:id])
    if @plugin_feature.update_attributes(params[:plugin_feature])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.item_save", :item => PluginFeatureValue.model_name.human, :name => "#{@plugin_feature.name}"))       
      flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)
      redirect_to :action => "edit", :controller => "plugin_features", :id => @plugin_feature.id
     else
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)
      render :action => "edit"
   end
  
 end
 
  def create_option # creates a new Feature value option
    @plugin_feature = PluginFeature.find(params[:id])
    @plugin_feature_value_option = PluginFeatureValueOption.new(params[:plugin_feature_value_option])
    @plugin_feature_value_option.plugin_feature_id = @plugin_feature.id
    
    if @plugin_feature_value_option.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => t("log.item_create", :item => PluginFeatureValueOption.model_name.human, :name => "#{@plugin_feature_value_option.value}")) 
      flash[:success] = t("notice.item_create_success", :item =>  PluginFeatureValueOption.model_name.human)
      redirect_to :action => "options", :controller => "plugin_features", :id => @plugin_feature_value_option.plugin_feature_id
     else
      flash[:failure] = t("notice.item_create_failure", :item =>  PluginFeatureValueOption.model_name.human)
      render :action => "options"
    end
    
  end
 
  def delete_option # deletes feature value option 
    @plugin_feature_value_option = PluginFeatureValueOption.find(params[:id])
    if @plugin_feature_value_option.destroy
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.item_delete", :item => PluginFeatureValueOption.model_name.human, :name => "#{@plugin_feature_value_option.value}")) 
      flash[:success] = t("notice.item_delete_success", :item =>  PluginFeatureValueOption.model_name.human)
     else
      flash[:failure] = t("notice.item_delete_failure", :item =>  PluginFeatureValueOption.model_name.human)
    end
    
    redirect_to :action => "options", :controller => "plugin_features", :id => @plugin_feature_value_option.plugin_feature_id
  end 
 
  def update_values
    feature_errors = PluginFeature.check(:features => params[:features], :item => @item) # check if required features are present
    if feature_errors.size == 0 # make sure there's not required feature errors
      # Update Feature Valuess
      approve = (!@group_permissions_for_plugin.requires_approval?  || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?) # check if these new values will be auto-approved 
      num_of_features_updated = PluginFeature.create_values_for_item(:item => @item, :features => params[:features], :user => @logged_in_user, :delete_existing => true, :approve => approve)  
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => t("log.item_save", :item => @plugin.model_name.human, :name => "#{@plugin.model_name.human(:count => num_of_features_updated)}" ))                    
      if approve
        flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)
      else 
        flash[:success] = t("notice.item_needs_approval", :item => @plugin.model_name.human)        
      end 
    else # failed adding required features
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)          
    end  
    redirect_to :action => "edit_values" , :id => @item            
  end
  
  def options 
    @plugin_feature = PluginFeature.find(params[:id])
    @plugin_feature_value_option = PluginFeatureValueOption.new
  end
end
