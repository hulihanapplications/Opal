class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name, :value
  
  scope :global, where("record_id is ? and record_type is ?", nil, nil)  
  
  cattr_accessor :global_settings # Setting.global_settings       
  
  def validate
  end

  def self.get_setting(name) # get a setting from the database, usually text-based string
    setting = Setting.find_by_name(name)
    return setting.to_s
  rescue # ActiveRecord not found
    return ""
  end
  
  def self.get_setting_bool(name) # get a setting from the database return true or false depending on "1" or "0"
    setting = Setting.find_by_name(name)
	  setting.to_bool
  rescue # ActiveRecord not found
    return false
  end  
  
  def self.get_global_settings
    begin
  	  logger.info "Retrieving global settings."    
  	  setting_array = Setting.global # get ALL settings    
  	  setting = setting_array.hash_by(:name, :to_value) # convert array to hash, indexed by name, value by to_value
  	  setting[:title] = setting[:site_title]
  	  setting[:description] = setting[:site_description]
  	  setting[:theme_url] =  "/themes/#{setting[:theme]}" # url for theme directory
  	  setting[:themes_dir] =  File.join(Rails.root.to_s, "public", "themes") # system path for main themes directory 
  	  setting[:theme_dir] =  File.join(setting[:themes_dir], setting[:theme]) # system path for current theme directory 
  	  setting[:default_preview_type] =  setting[:default_preview_type].constantize if setting[:default_preview_type]
  	  Rails.application.config.action_mailer.default_url_options = { :host => setting[:host] ? setting[:host] : "localhost" } # set actionmailer host 
  	  # Autoload plugin settings
  	  Plugin.plugins.each do |name, plugin|
  	    setting[plugin.plugin_class.name.underscore.to_sym] = PluginSetting.plugin(plugin).all.hash_by(:name, :to_value) 
  	  end  	  
    rescue Exception => e
      logger.info e
      setting = Hash.new
   	end
    return setting
  end
  
  def to_param # make custom parameter generator for friendly urls
    "#{id}-#{name.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  def title
    return I18n.t("activerecord.records.setting.#{self.name.downcase}.title", :default => self.name.humanize)
  end
  
  def description
    return I18n.t("activerecord.records.setting.#{self.name}.description", :default => "")
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
  
  # change setting
  def self.set(name, value)
    find_by_name(name).update_attribute(:value, value)
    reload
  end  
  
  # reload settings from database and store/cache in cattr
  def self.reload
    self.global_settings = table_exists? ? Setting.get_global_settings : Hash.new # load global settings into metaclass variable    
  end
  
  # Load settings for the first time when model is loaded
  reload  
end
