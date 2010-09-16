class PluginFeatureValue < ActiveRecord::Base
  # Dave: the plugin_feature_value is an interest type of plugin, it actually 
  #       is a child of another psuedo plugin, the plugin_feature. I want plugin
  #       functionality to be able to support inheritance, not just a plain pointer to an
  #       plugin_whatever value set. 
  belongs_to :plugin_feature
  belongs_to :item
  belongs_to :user
  
  validates_presence_of :value
  validates_uniqueness_of  :item_id, :scope => :plugin_feature_id, :message => "There is already a value for this."
  attr_protected :item_id

  def is_approved?
     if self.is_approved == "1"
       return true
     else # not approved
       return false
     end
  end
end
