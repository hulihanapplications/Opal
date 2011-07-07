class PluginSetting < ActiveRecord::Base
  belongs_to :plugin
  validates_uniqueness_of :name, :scope => :plugin_id
  
  def title
    return I18n.t("activerecord.records.plugin_setting.#{self.name.downcase}.title", :default => self.name.humanize)
  end
  
  def description
    return I18n.t("activerecord.records.plugin_setting.#{self.name}.description", :default => "")
  end
end
