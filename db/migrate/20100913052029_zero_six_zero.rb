class ZeroSixZero < ActiveRecord::Migration
  def self.up
   Setting.find_by_name("opal_version").update_attribute(:value, "0.6.0") # Update Version    
   
   # Create Setting that determines if they set up their Application for the first time.
   Setting.create(:name => "setup_completed",  :title => nil, :value => "0", :description => nil, :item_type => "bool", :setting_type => "Hidden")   
   
   # Create default system language setting
   Setting.create(:name => "locale",  :title => nil, :value => "en", :description => nil, :item_type => "special", :setting_type => "Public")
   
   # Create User's default locale, takes precedence over system
   add_column :users, :locale, :string, :default => nil

   # Eliminate Custom Plugin Titles
   remove_column :plugins, :title   

   # Create Item Locking 
   add_column :items, :locked, :bool, :default => false   
  
  end

  def self.down
  end
end
