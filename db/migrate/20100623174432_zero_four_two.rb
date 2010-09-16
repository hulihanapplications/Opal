class ZeroFourTwo < ActiveRecord::Migration
  def self.up
    Setting.find_by_name("opal_version").update_attribute(:value, "0.4.2") # Update Version    

    # New Setting Changes
    Setting.create(:name => "homepage_type",  :title => "Homepage Type", :value => "new_items", :setting_type => "Hidden", :description => "This is what is shown in main section of Opal's homepage.", :item_type => "string")
    Setting.create(:name => "item_page_type",  :title => "Item Page Type", :value => "tabs_horizontal", :setting_type => "Hidden", :description => "This is the layout of each item's page.", :item_type => "string")
    Setting.find_by_name("plugin_list_type").destroy # destroy the old item plugin_list_type settings, since it will be replaced by item_page_type
    Setting.find_by_name("display_new_items").destroy # destroy the "Display New Items" setting, since it's being combined into the new homepage_type setting.
   
    
    # Add new columns to Features to extend functionality
    add_column :plugin_features, :is_required, :bool, :default => false # makes a feature required for an item
    add_column :plugin_features, :feature_type, :string, :default => "text" # allows for different data type handling & parsing: string, integer, bool, float, date, slider, etc. 
    add_column :plugin_features, :default_value, :string, :default => nil # to specify the default value for a feature. 

    # Add new columns to pages 
    add_column :pages, :name, :string, :default => nil# constant to look up page, besides id     
    add_column :pages, :deletable, :boolean, :default => true # if page can be deleted    
    add_column :pages, :title_editable, :boolean, :default => true # if title can be edited
    add_column :pages, :description_editable, :boolean, :default => true # if description can be edited    
    add_column :pages, :content_editable, :boolean, :default => true # if content can be edited
    Page.reset_column_information


 
  end

  def self.down
  end
end
