class PluginSetting < ActiveRecord::Base
  belongs_to :plugin
  validates_uniqueness_of :name, :scope => :plugin_id
  

end
