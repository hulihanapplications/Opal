class ZeroSevenFour < ActiveRecord::Migration
  def self.up
    add_column :items, :preview_class, :string
    add_column :items, :preview_id, :integer 
    
    add_column :plugin_reviews, :plugin_review_category_id, :integer
    Setting.create(:name => "default_preview_class",  :value => "PluginImage", :setting_type => "Hidden", :item_type => "string") # when a plugin record is created for an item, its preview will be set to this       
  end

  def self.down
  end
end
