class PluginSetting < ActiveRecord::Base
  belongs_to :plugin
  validates_uniqueness_of :name, :scope => :plugin_id, :message => "There is already an Plugin Setting with this name and plugin_id."
  

end
