class Plugin < ActiveRecord::Base
  validates_presence_of :name, :title
  validates_uniqueness_of :name, :message => "There is already a Plugin with this name."
  has_many :plugin_settings
  has_many :group_plugin_permissions
  
  after_create :create_everything
  after_destroy :destroy_everything

  default_scope :order => "order_number ASC" # override default find
  named_scope :enabled, :conditions => {:is_enabled => '1'} # Get all enabled Item Objects with Plugin.enabled
  
  
  def create_everything
    # auto assign order number
    self.update_attribute(:order_number, Plugin.next_order_number) # assign next order number
  end
  
  
  def destroy_everything
    for item in self.plugin_settings # Delete plugin_settings
      item.destroy
    end
    
    for item in self.group_plugin_permissions
      item.destroy
    end
    
    # Delete Plugin Objects for Items
    for item in self.child_find(:all)
      item.destroy
    end
        
  end 
  
  # The Plugin is not a child of an Object, instead it is a type of view that will be displayed for all items. 
  # Notes: order_number must be 0 indexed because of each_index in the sorting method  
  def is_enabled?
    return self.is_enabled == "1"
  end
  
  def is_builtin?
    return self.is_builtin == "1"
  end
  
  def self.next_order_number # >> Returns the next order_number. Example: Plugin.next_order_number => 8 
    last_plugin = self.find(:last, :order => "order_number ASC")
    return last_plugin.order_number + 1
  end
  
    
  def get_setting(name) # get an PluginSetting from the database
   setting = PluginSetting.find(:first, :conditions => ["name = ? and plugin_id = ?", name, self.id], :limit => 1 )
   return setting.value
   rescue # ActiveRecord not found
     return false   
  end
   
  def get_setting_bool(name) # get an PluginSetting from the database return true or false depending on "1" or "0"
   setting = PluginSetting.find(:first, :conditions => ["name = ? and plugin_id = ?", name, self.id], :limit => 1 )
   if setting.value == "1"
     return true
   else # not true
     return false
   end
   rescue # ActiveRecord not found
     return false
  end

  def child_find(*args) # accesses associated Plugin Child(ie: PluginImages)
    child_name = "plugin_" + self.name # create child name, ie: plugin_images
    child_name.camelize.constantize.find(*args)
  end
  
  def partial_path(options = {}) # returns the file location for the partial of a particular type
    options[:type] ||= "list" # set default
    return "/plugin_#{self.name.downcase}s/#{options[:type]}"    
  end

  def permissions_for_group(group) # retrieve ONE plugin's permissions for a certain group    
    group_plugin_permissions = GroupPluginPermission.find(:first, :conditions => ["plugin_id = ? and group_id = ?", self.id, group.id])
    group_plugin_permissions ||= GroupPluginPermission.new(:plugin_id => self.id, :group_id => group.id) # initialize default permissions if no records are found.
 
    return group_plugin_permissions    
  end
  
  def self.find_plugin_items(*args) # retrieve plugin items(psuedo-children) for every plugin. Returns a hash of arrays indexed by plugin id.
    # Rules: you can only search by common attributes shared by all plugin items, otherwise you'll be looking for a unique attribute that won't be shared by all plugins. 
    # Here are the currently shared attributes: item_id, user_id, is_approved, created_at, updated_at 
   
    plugin_item_count = 0 # set count
    plugin_items = Hash.new # hash to store arrays
    for plugin in Plugin.enabled
      if plugin.name != "Feature" && plugin.name != "FeatureValue" # exclude special plugins we won't search
        plugin_items[plugin.id] = plugin.child_find(*args) # find plugin items
        plugin_item_count += plugin_items[plugin.id].size
      end   
    end      
    
    if plugin_item_count == 0 # return 0 if no plugin items were found, so we can handle it properly 
      return 0
    else # at least one plugin item was found
      return plugin_items
    end 
  end
  
end
