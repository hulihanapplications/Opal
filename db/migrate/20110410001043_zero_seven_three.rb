class ZeroSevenThree < ActiveRecord::Migration
  def self.up
    add_column :users, :salt, :string
    add_column :plugin_features, :category_id, :integer
    
    # Create Video Plugin
    plugin = Plugin.new(:name => "Video", :is_enabled => "1", :is_builtin => "1")
    if plugin.save
      PluginSetting.create(:plugin_id => plugin.id, :name => "video_display_mode",   :value => "List", :options => "Full, List",  :item_type => "option")
    end 
  end

  def self.down
  end
end
