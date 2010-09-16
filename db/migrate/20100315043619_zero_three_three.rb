class ZeroThreeThree < ActiveRecord::Migration
  def self.up
    # Update Opal Version
    Setting.find_by_name("opal_version").update_attribute(:value, "0.3.3") 
    # Add New Search Type Field for Plugins
    add_column(:plugin_features, :search_type, :string, :default => "Grouped") # Some search types for plugins: text, grouped_select, no_search(no searching for that plugin, comparison(two values to compare against), etc. 

    
  end

  def self.down
  end
end
