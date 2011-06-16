class ZeroSevenThree < ActiveRecord::Migration
  def self.up
    add_column :users, :salt, :string
    add_column :plugin_features, :category_id, :integer
    
    # Create Video Plugin
    plugin = Plugin.create(:name => "Video", :order_number => Plugin.next_order_number, :is_enabled => "1", :is_builtin => "1")
        PluginSetting.create(:plugin_id => plugin.id, :name => "video_display_mode",   :value => "Full", :options => "Full, List",  :item_type => "option")        
  end

  def self.down
  end
end
