class CreatePluginSettings < ActiveRecord::Migration
  def self.up
    create_table :plugin_settings do |t|
      t.column :plugin_id, :integer
      t.column :name, :string 
      t.column :setting_type, :string
      t.column :value, :string
      t.column :item_type, :string
      t.timestamps
      t.column :options, :string, :default => nil
    end

    PluginSetting.create(:plugin_id => Plugin.find_by_name("Image").id, :name => "slideshow_speed",   :value => "2500", :setting_type => "System", :item_type => "string")
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Image").id, :name => "item_thumbnail_width",  :value => "180", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Image").id, :name => "item_thumbnail_height",   :value => "125", :setting_type => "Plugin",  :item_type => "string")           
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Image").id, :name => "resize_item_images",   :value => "0", :setting_type => "Plugin",  :item_type => "bool")   
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Image").id, :name => "item_image_width",   :value => "500", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Image").id, :name => "item_image_height",  :value => "500", :setting_type => "Plugin", :item_type => "string")        

    PluginSetting.create(:plugin_id => Plugin.find_by_name("Review").id, :name => "review_type", :value => "Stars", :item_type => "option", :options => "Stars, Slider, Number")
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Review").id, :name => "score_min",  :value => "0",  :item_type => "string")
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Review").id, :name => "score_max",   :value => "5",  :item_type => "string")        
  
    PluginSetting.create(:plugin_id => Plugin.find_by_name("File").id, :name => "login_required_for_download",   :value => "0", :setting_type => "System",  :item_type => "bool")
    PluginSetting.create(:plugin_id => Plugin.find_by_name("File").id, :name => "log_downloads",  :value => "0", :setting_type => "System", :item_type => "bool")       
  end

  def self.down
    drop_table :plugin_settings
  end
end
