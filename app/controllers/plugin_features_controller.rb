class PluginFeaturesController < ApplicationController
  #before_filter :authenticate_user
  before_filter :find_record, :except => [:new, :create, :delete, :index, :edit, :update, :create_option, :delete_option, :options] # look up item 
  before_filter :find_plugin # look up plugin
  before_filter :authenticate_admin, :enable_admin_menu, :only =>  [:create, :delete, :index, :new, :edit, :update, :create_option, :delete_option, :options] # make sure logged in user is an admin  
  before_filter(:only => [:create_feature_values]){|c| can?(PluginFeatureValue, @logged_in_user, :create)} 
  before_filter(:only => [:update_feature_value, :update_values]){|c| can?(@record.record, @logged_in_user, :edit)} 
  before_filter(:only => [:delete_feature_values]){|c| can?(@record.record, @logged_in_user, :edit)} 

  include ActionView::Helpers::TextHelper # for truncate, etc.
  
  def create_feature_values
   flash_msg = "" 
   #for i in 0..params[:features].size  # for every feature available to add
   params[:features].each do | id, feature |
     if feature && feature[:value] != "" # if array item has something in it and at least value was filled out
       feature_value = PluginFeatureValue.new(feature)
       feature_value.user_id = @logged_in_user.id
       feature_value.record = @item             
       if feature_value.save
          log(:log_type => "create", :target => feature_value)
          flash[:success] = t("notice.item_create_success", :item => PluginFeatureValue.model_name.human + "(#{feature_value.plugin_feature.name})") + "<br>"
          flash[:success] +=  t("notice.item_needs_approval", :item => @plugin.model_name.human) + "<br>"  if !feature_value.is_approved?             
       else # fail saved 
          flash_msg += t("notice.item_create_failure", :item => @plugin.model_name.human)
       end 
     end 
   end
   flash[:notice] = flash_msg     
   redirect_to :back
  end

  def update_feature_value
   @plugin_feature_value = PluginFeatureValue.find(params[:feature_value_id])
   @plugin_feature = PluginFeature.find(@plugin_feature_value.plugin_feature_id)
   if @plugin_feature_value.update_attributes(:value => params[:feature_value][:value], :url => params[:feature_value][:url])
    log(:log_type => "update", :target => @plugin_feature_value)
    flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)
   else # fail saved 
    flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)
   end    
   redirect_to :back
  end
 
  def delete_feature_value
   @plugin_feature_value = PluginFeatureValue.find(params[:feature_value_id])
   if @plugin_feature_value.destroy
    log(:log_type => "destroy", :target => @plugin_feature_value)
    flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
   else # fail saved 
       flash[:failure] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
   end 
   redirect_to :back
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
      log(:log_type => "create", :target => @plugin_feature)
      flash[:success] = t("notice.item_create_success", :item => @plugin.model_name.human)
      redirect_to :back
     else
      flash[:failure] = t("notice.item_create_failure", :item => @plugin.model_name.human)
      render :action => "new"
    end
    
  end
 
  def delete # deletes feature 
    @plugin_feature = PluginFeature.find(params[:id])
    if @plugin_feature.destroy
      log(:log_type => "destroy", :target => @plugin_feature)
      flash[:success] = t("notice.item_delete_success", :item => @plugin.model_name.human)
     else
      flash[:failure] = t("notice.item_delete_failure", :item => @plugin.model_name.human)
    end
    
    redirect_to :back
  end 

 def edit
   @plugin_feature = PluginFeature.find(params[:id])
   @plugin_feature_value_option = PluginFeatureValueOption.new(:plugin_feature_id => @plugin_feature.id)
 end
 
 def update
    @plugin_feature = PluginFeature.find(params[:id])
    if @plugin_feature.update_attributes(params[:plugin_feature])
      log(:log_type => "update", :target => @plugin_feature)
      flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)
      redirect_to :back
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
      log(:log_type => "create", :target => @plugin_feature_value_option)
      flash[:success] = t("notice.item_create_success", :item =>  PluginFeatureValueOption.model_name.human)
      redirect_to :back
     else
      flash[:failure] = t("notice.item_create_failure", :item =>  PluginFeatureValueOption.model_name.human)
      render :action => "options"
    end
    
  end
 
  def delete_option # deletes feature value option 
    @plugin_feature_value_option = PluginFeatureValueOption.find(params[:id])
    if @plugin_feature_value_option.destroy
      log(:log_type => "destroy", :target => @plugin_feature_value_option)
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
      if approve
        flash[:success] = t("notice.item_save_success", :item => @plugin.model_name.human)
      else 
        flash[:success] = t("notice.item_needs_approval", :item => @plugin.model_name.human)        
      end 
    else # failed adding required features
      flash[:failure] = t("notice.item_save_failure", :item => @plugin.model_name.human)          
    end  
    redirect_to :back
  end
  
  def options 
    @plugin_feature = PluginFeature.find(params[:id])
    @plugin_feature_value_option = PluginFeatureValueOption.new
  end
end
