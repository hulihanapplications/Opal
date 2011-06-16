class PluginController < ApplicationController
 before_filter :find_item # look up item 
 before_filter :find_plugin # look up item  
 before_filter :get_group_permissions_for_plugin # get permissions for this plugin
 before_filter :check_item_view_permissions # can user view item? 
 before_filter :check_item_edit_permissions, :only => [:change_approval] # list of actions that don't require that the item is editable by the user
 before_filter :can_group_create_plugin, :only => [:new, :create]
 before_filter :can_group_update_plugin, :only => [:edit, :update] 
 before_filter :can_group_delete_plugin, :only => [:delete]  
end
