class GroupPluginPermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :plugin
  
  validates_uniqueness_of :group_id, :scope => :plugin_id 
  
  
  def self.all_plugin_permissions_for_group(group) # retrieve plugin permissions for a certain group
    plugins = Plugin.find(:all, :conditions => ["is_enabled = '1'"])
    
    gpp_hash = Hash.new # create plugins permissions hash to lighten load on db. This prevents us from having to make a db query for every permission(creation, reading, deleting, etc.) for each plugin. This adds up to a lot of queries!
    
    for plugin in plugins
      gpp_hash[plugin.plugin_class.name] = GroupPluginPermission.for_plugin_and_group(plugin, group)
    end
    
    return gpp_hash    
  end
  
  def self.group(group)
    where("group_id = ?", group.id)
  end

  
  def self.plugin(plugin)
    where(:plugin_id => plugin.id)
  end
  
  def self.for_plugin_and_group(plugin, group)
    gpp = GroupPluginPermission.group(group).plugin(plugin).first
    gpp ||= GroupPluginPermission.new(:plugin_id => plugin.id, :group_id => group.id) # initialize default permissions if no records are found.
    return gpp
  end

  # interpret action to match attribute, ie: group_plugin_permission.can?(:create) => true
  def can?(action)
    case action.to_sym
    when :create, :new
      can_create == "1"
    when :read, :view
      can_read == "1"
    when :delete, :destroy
      can_delete == "1"
    when :edit, update
      can_update == "1"
    when :requires_approval
      requires_approval == "1"
    end 
  end
  
  def can_create?
    self.can_create == "1"
  end

  def can_read?
    self.can_read == "1"
  end
  
  def can_update?
    self.can_update == "1"
  end

  def can_delete?
    self.can_delete == "1"
  end
  
  def requires_approval?
    self.requires_approval == "1"  
  end
end
