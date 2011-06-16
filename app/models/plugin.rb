class Plugin < ActiveRecord::Base
  # The Plugin Model is a unique one. Every Plugin object record belongs to an associated Model with the same name as the plugin object, so if the record's name is "Image", it's associated model is PluginImage. This allows Opal to organize Models of a particular type(so you can change order, etc.).
  
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :plugin_settings
  has_many :group_plugin_permissions
  
  after_create :create_everything
  after_destroy :destroy_everything
  
  before_validation(:on => :create) do 
    self.assign_order_number
  end 

  default_scope :order => "order_number ASC" # override default find
  
  scope :third_party, where(:is_builtin => "0")
  
  def actual_model # returns the Class of plugin that this plugin object points to. Example: Plugin.find_by_name("Image").actual_model => PluginImage 
    return "Plugin#{self.name}".camelize.constantize
  end
    
  # Set plugins to metaclass
  class << self # open up metaclass  
    attr_accessor :plugins, :third_party_plugins # Plugin.plugins
    
    def enabled      
      where(["enabled = ?", "1"]).order("order_number ASC")
    end
  end    

  def self.all_to_hash # return all plugins in an unordered hash
    plugin_hash = Hash.new
    for plugin in self.find(:all, :order => "order_number ASC")
      plugin_hash[plugin.name.underscore.to_sym] = plugin
    end
    return plugin_hash
  end
  
  if ActiveRecord::Base.connection.tables.include?('plugins') # check if table exists
    self.plugins = Plugin.all_to_hash # store all plugins in Plugin.plugins
    self.third_party_plugins = Plugin.third_party
  end 
  
  def create_everything   
    # Create Group Plugin Permissions
    for group in Group.all
      GroupPluginPermission.create(:group_id => group.id, :plugin_id => self.id, :can_read => "1") # turn on read permissions for users
    end     
  end
  
  def model_name # get human/translated name of plugin child 
    self.plugin_class.model_name # get human name of actual model 
  end
  
  def destroy_everything
    for item in self.plugin_settings # Delete plugin_settings
      item.destroy
    end
    
    for item in self.group_plugin_permissions
      item.destroy
    end
    
    # Delete Plugin Objects for Items
    for item in self.actual_model.find(:all)
      item.destroy
    end
  end 
  
  def self.enabled # get all enabled plugins
    self.find(:all, :conditions => ["is_enabled = ?", "1"], :order => "order_number ASC")
  end
  
  # The Plugin is not a child of an Object, instead it is a type of view that will be displayed for all items. 
  # Notes: order_number must be 0 indexed because of each_index in the sorting method  
  def is_enabled?
    return self.is_enabled == "1"
  end
  
  def is_builtin?
    return self.is_builtin == "1"
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

  def partial_path(options = {}) # returns the file location for the partial of a particular type
    options[:type] ||= "list" # set default
    return "/plugin_#{self.name.underscore.pluralize}/#{options[:type]}"    
  end

  def permissions_for_group(group) # retrieve ONE plugin's permissions for a certain group    
    group_plugin_permissions = GroupPluginPermission.find(:first, :conditions => ["plugin_id = ? and group_id = ?", self.id, group.id])
    group_plugin_permissions ||= GroupPluginPermission.new(:plugin_id => self.id, :group_id => group.id) # initialize default permissions if no records are found. 
    return group_plugin_permissions    
  end

  # Deprecated as of Opal 0.6.0
  def child_find(*args) # accesses associated Plugin Child(ie: PluginImages)
    child_name = "plugin_" + self.name # create child name, ie: plugin_images
    child_name.camelize.constantize.find(*args)
  end
    
  # Deprecated as of Opal 0.6.0
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
  
  def plugin_class # get the class that this plugin record is tied to
    "Plugin#{self.name}".constantize
  end
  
end
