class PluginSetting < ActiveRecord::Base
  belongs_to :plugin
  
  validates_presence_of :name
  validates_presence_of :plugin_id
  validates_uniqueness_of :name, :scope => :plugin_id
  
  def self.plugin(plugin)
    where("plugin_id = ?", plugin.id)
  end
  
  def title
    return I18n.t("activerecord.records.plugin_setting.#{self.name.downcase}.title", :default => self.name.humanize)
  end
  
  def description
    return I18n.t("activerecord.records.plugin_setting.#{self.name}.description", :default => "")
  end
  
  def to_bool
    value == "1"
  end
  
  def to_s
    value
  end
  
  def to_value # return a value based on setting type
    item_type == "bool" ? to_bool : to_s 
  end   
end
