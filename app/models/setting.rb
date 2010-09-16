class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name, :value
  
  def validate
  end
  
  def self.global_settings
    setting = Hash.new
    setting[:item_name] = Setting.get_setting("item_name")
    setting[:item_name_plural] = Setting.get_setting("item_name_plural")
    setting[:title] = Setting.get_setting("site_title")
    setting[:description] = Setting.get_setting("site_description")
    setting[:meta_keywords] = Setting.get_setting("site_keywords")
    setting[:meta_description] = setting[:description]
    setting[:meta_title] = setting[:title] + " - " + setting[:meta_description]
    setting[:theme] = Setting.get_setting("theme")
    setting[:items_per_page] = Setting.get_setting("items_per_page")
    setting[:include_child_category_items] = Setting.get_setting_bool("include_child_category_items")
    setting[:theme_dir] =  "/themes/#{setting[:theme]}"
    return setting
  end
  
  def to_param # make custom parameter generator for seo urls
    "#{id}-#{name.gsub(/[^a-z0-9]+/i, '-')}"
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
  
end
