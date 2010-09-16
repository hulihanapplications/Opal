class ZeroOneEightNewFeatures < ActiveRecord::Migration
  def self.up
    add_column(:user_infos, :use_gravatar, :string, :default => "0", :limit => 1)    
    add_column(:plugin_features, :icon_url, :string, :default => nil) # filename for the icon of the feature. looks in images/icons in the theme folder.
    Setting.create(:name => "include_child_category_items", :title => "Include Child Category Items",  :value => "1", :setting_type => "Item", :description => "If enabled, all Child Category Items will be included in lists and number counts for the Parent Category. Enabling this creates a small performance drop.", :item_type => "bool")        
  end

  def self.down
  end
end
