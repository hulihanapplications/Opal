class GroupPluginPermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :plugin
  
  validates_uniqueness_of :group_id, :scope => :plugin_id 
  
  
  def self.all_plugin_permissions_for_group(group) # retrieve plugin permissions for a certain group
    plugins = Plugin.find(:all, :conditions => ["is_enabled = '1'"])
    
    group_plugin_permissions = Hash.new # create plugins permissions hash to lighten load on db. This prevents us from having to make a db query for every permission(creation, reading, deleting, etc.) for each plugin. This adds up to a lot of queries!
    
    for plugin in plugins
      group_plugin_permissions[plugin.plugin_class.name] = GroupPluginPermission.find(:first, :conditions => ["plugin_id = ? and group_id = ?", plugin.id, group.id])
      group_plugin_permissions[plugin.plugin_class.name] ||= GroupPluginPermission.new(:plugin_id => plugin.id, :group_id => group.id) # initialize default permissions if no records are found.
    end
    
    return group_plugin_permissions    
  end
  
  def can_create?
    if self.can_create == "1"
      return true
    else 
      return false
    end
  end

  def can_read?
    if self.can_read == "1"
      return true
    else 
      return false
    end
  end
  
  def can_update?
    if self.can_update == "1"
      return true
    else 
      return false
    end
  end

  def can_delete?
    if self.can_delete == "1"
      return true
    else 
      return false
    end
  end
  
  def requires_approval?
    if self.requires_approval == "1"
      return true
    else 
      return false
    end    
  end
end
