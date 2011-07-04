class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name, :value
  
  class << self # open up metaclass  
    attr_accessor :global_settings # Setting.global_settings
  end     
  
  def validate
  end

  def self.get_setting(name) # get a setting from the database, usually text-based string
    setting = Setting.find(:first, :conditions => ["name = ?", name], :limit => 1 )
    return setting.value
  rescue # ActiveRecord not found
    return ""
  end
  
  def self.get_setting_bool(name) # get a setting from the database return true or false depending on "1" or "0"
    setting = Setting.find(:first, :conditions => ["name = ?", name], :limit => 1 )
    if setting.value == "1"
      return true
    else # not true
      return false
    end
  rescue # ActiveRecord not found
    return false
  end
  
  
  def self.get_global_settings
    logger.info "Retrieving global settings."
    setting = Hash.new
    setting[:title] = Setting.get_setting("site_title")
    setting[:description] = Setting.get_setting("site_description")
    setting[:theme] = Setting.get_setting("theme")
    setting[:items_per_page] = Setting.get_setting("items_per_page")
    setting[:include_child_category_items] = Setting.get_setting_bool("include_child_category_items")
    setting[:theme_url] =  "/themes/#{setting[:theme]}" # url for theme directory
    setting[:themes_dir] =  File.join(Rails.root.to_s, "public", "themes") # system path for main themes directory 
    setting[:theme_dir] =  File.join(setting[:themes_dir], setting[:theme]) # system path for current theme directory 
    setting[:section_blog] =  Setting.get_setting_bool("section_blog")
    setting[:section_items] =  Setting.get_setting_bool("section_items")
    setting[:allow_user_registration] =  Setting.get_setting_bool("allow_user_registration")
    setting[:allow_public_access] =  Setting.get_setting_bool("allow_public_access")  
    setting[:default_preview_class] =  Setting.get_setting("default_preview_class").constantize    
    setting[:locale] =  Setting.get_setting("locale")    
    return setting
  end

  self.global_settings = Setting.get_global_settings # load global settings into metaclass variable

  
  def to_param # make custom parameter generator for friendly urls
    "#{id}-#{name.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  def title
    return I18n.t("activerecord.records.setting.#{self.name.downcase}.title", :default => self.name.humanize)
  end
  
  def description
    return I18n.t("activerecord.records.setting.#{self.name}.description", :default => "")
  end  
end
