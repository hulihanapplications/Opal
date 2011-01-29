class PluginSetting < ActiveRecord::Base
  belongs_to :plugin
  validates_uniqueness_of :name, :scope => :plugin_id
  
  def title
    return I18n.t("setting.title.#{self[:name].downcase}", :default => self[:title])
  end 

end
