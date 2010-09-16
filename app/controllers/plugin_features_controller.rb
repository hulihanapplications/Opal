class PluginFeaturesController < ApplicationController
 #before_filter :authenticate_user
 before_filter :find_item, :except => [:new, :create, :delete, :index, :edit, :update, :create_option, :delete_option] # look up item 
 before_filter :find_plugin # look up plugin
 before_filter :get_my_group_plugin_permissions # get permissions for this plugin  
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 before_filter [:authenticate_admin, :enable_admin_menu] , :only =>  [:create, :delete, :index, :new, :edit, :update, :create_option, :delete_option] # make sure logged in user is an admin  


 def find_plugin # find the plugin that is being used 
   @plugin = Plugin.find(:first, :conditions => ["name = ?", "Feature"])
   if @plugin.is_enabled? # check to see if the plugin is enabled
     # Proceed
   else # Plugin Not enabled
      flash[:notice] = "<div class=\"flash_failure\">Sorry, #{@plugin.title}s aren't enabled.</div>"
      redirect_to :action => "index", :controller => "browse"       
   end
 end

  
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
            Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => "Added a new #{@plugin.title}. #{feature_value.plugin_feature.name}: #{feature_value.value}.") 
            flash_msg += "<div class=\"flash_success\">New #{@plugin.title} Added! #{feature_value.plugin_feature.name}: <b>#{feature_value.value}</b> </div>"
            flash[:notice] += "<div class=\"flash_success\">This #{@plugin.title} needs to be approved before it will be displayed.</div>" if !feature_value.is_approved?             
         else # fail saved 
            flash_msg += "<div class=\"flash_failure\">New #{@plugin.title} Could not be Added! #{feature_value.plugin_feature.name}: <b>#{feature_value.value}</b> </div>"
         end 
       end 
     end
    flash[:notice] = flash_msg 
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot create #{@plugin.title}s.</div>"        
   end     
    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end

  def update_feature_value
   if @my_group_plugin_permissions.can_update? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?    
     @feature_value = PluginFeatureValue.find(params[:feature_value_id])
     @feature = PluginFeature.find(@feature_value.plugin_feature_id)
     log_msg = "Updated #{@plugin.title}: #{@feature.name}. #{@feature_value.value} changed to #{params[:feature_value][:value]}."
     if @feature_value.update_attributes(:value => params[:feature_value][:value], :url => params[:feature_value][:url])
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)        
      flash[:notice] = "<div class=\"flash_success\">#{@plugin.title}: <b>#{@feature.name}</b> Updated!</div>"
     else # fail saved 
      flash[:notice] = "<div class=\"flash_failure\">Update Failed!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot update #{@plugin.title}s.</div>"        
   end    
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end
 
  def delete_feature_value
   if @my_group_plugin_permissions.can_delete? || @item.is_user_owner?(@logged_in_user) || @logged_in_user.is_admin?       
     @feature_value = PluginFeatureValue.find(params[:feature_value_id])
     if @feature_value.destroy
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => "Deleted #{@plugin.title} Value. #{@feature_value.value} deleted from #{@feature_value.plugin_feature.name}.") 
      flash[:notice] = "<div class=\"flash_success\">#{@plugin.title}: <b>#{@feature_value.value}</b> Deleted!</div>"
     else # fail saved 
         flash[:notice] = "<div class=\"flash_failure\">Delete Failed!</div>"
     end
   else # Improper Permissions  
        flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot delete #{@plugin.title}s.</div>"        
   end      
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end

 def change_approval
    @feature_value = PluginFeatureValue.find(params[:feature_value_id])    
    if  @feature_value.is_approved?
      approval = "0" # set to unapproved if approved already    
      log_msg = "Unapproved #{@plugin.title} from #{@feature_value.user.username}."
    else
      approval = "1" # set to approved if unapproved already    
      log_msg = "Approved #{@plugin.title} from #{@feature_value.user.username}."
    end
    
    if @feature_value.update_attribute(:is_approved, approval)
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => log_msg)      
      flash[:notice] = "<div class=\"flash_success\">This <b>#{@plugin.title}</b>'s approval has been changed!</div>"
    else
      flash[:notice] = "<div class=\"flash_failure\">This <b>#{@plugin.title}</b>'s approval could not be changed for some reason!</div>"
    end
   redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s" 
  end 
 
  # Admin Only Methods 
  def create # creates a new Feature, not a Feature Value
    @feature = PluginFeature.new(params[:feature])    
    if !params[:feature][:icon_url].nil?  && params[:feature][:icon_url] != ""
      @feature.icon_url = params[:feature][:icon_url]
    end
    
    if @feature.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => "Created #{@plugin.title}: #{@feature.name}.") 
      flash[:notice] = "<div class=\"flash_success\">New #{@plugin.title}: <b>#{params[:feature_name]}</b> created!</div>"
     else
      flash[:notice] = "<div class=\"flash_failure\">New #{@plugin.title}: <b>#{params[:feature_name]}</b> could not be created!<br>#{print_errors(@feature)}</div><br>"
    end
    
    redirect_to :action => "index", :controller => "plugin_features"  
  end
 
  def delete # deletes feature 
    @feature = PluginFeature.find(params[:id])
    if @feature.destroy
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => "Deleted #{@plugin.title}: #{@feature.name}(#{@feature.id}).")       
      flash[:notice] = "<div class=\"flash_success\">#{@plugin.title}: <b>#{@feature.name}</b> deleted!</div>"
     else
      flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title}: <b>#{@feature.name}</b> deletion failed!</div>"
    end
    
    redirect_to :action => "index", :controller => "plugin_features"  
  end 

 def edit
   @feature = PluginFeature.find(params[:id])
 end
 
 def update
    @feature = PluginFeature.find(params[:id])
    if @feature.update_attributes(params[:feature])
      Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Updated #{@plugin.title}: #{@feature.name}(#{@feature.id}).")       
      flash[:notice] = "<div class=\"flash_success\">#{@plugin.title}: <b>#{@feature.name}</b> updated!</div>"
     else
      flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title}: <b>#{@feature.name}</b> could not be saved!<br>#{print_errors(@feature)}</div>"
  end
  
  redirect_to :action => "edit", :controller => "plugin_features", :id => @feature.id
 end
 
  def create_option # creates a new Feature value option
    @option = PluginFeatureValueOption.new(params[:option])
    @option.plugin_feature_id = params[:id]
    
    if @option.save
      Log.create(:user_id => @logged_in_user.id, :log_type => "new", :log => "Created #{@plugin.title} Value Option: #{@option.value}.") 
      flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} Value Option: #{@option.value} created!</div>"
     else
      flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} Value Option: #{@option.value} could not be created!</div><br>"
    end
    
    redirect_to :action => "edit", :controller => "plugin_features", :id => @option.plugin_feature_id
  end
 
  def delete_option # deletes feature value option 
    @option = PluginFeatureValueOption.find(params[:id])
    if @option.destroy
      Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => "Deleted #{@plugin.title} Value Option: #{@option.value}.") 
      flash[:notice] = "<div class=\"flash_success\">#{@plugin.title} Value Option: #{@option.value} deleted!</div>"
     else
      flash[:notice] = "<div class=\"flash_failure\">#{@plugin.title} Value Option: #{@option.value} deletion failed!</div>"
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
      Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log => "Updated #{num_of_features_updated} #{@plugin.title}s.")                    
      if approve
        flash[:notice] = "<div class=\"flash_success\">Your changes have been saved.</div>"
      else 
        flash[:notice] = "<div class=\"flash_success\">Your changes have been saved, but they must be approved before they can be seen.</div>"        
      end 
    else # failed adding required features
      flash[:notice] = "<div class=\"flash_failure\">Your changes could not be saved! Here's why: <br>#{print_errors(feature_errors)}</div>"          
    end  
    redirect_to :action => "edit_values" , :id => @item    
   else # Improper Permissions  
    flash[:notice] = "<div class=\"flash_failure\">Sorry, you cannot update #{@plugin.title}s.</div>"
    redirect_to :action => "view", :controller => "items", :id => @item.id, :anchor => "#{@plugin.name}s"     
   end         
  end
end
