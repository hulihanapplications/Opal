class ZeroTwoOneNewFeatures < ActiveRecord::Migration
  def self.up
    # Add new Image Plugin Settings
    @plugin = Plugin.find_by_name("Image")
    PluginSetting.create(:plugin_id => @plugin.id, :name => "slideshow_speed", :title => "Slideshow Speed",  :value => "2500", :setting_type => "System", :description => "The speed of a slideshow, in milliseconds(ms). Default is 2500.", :item_type => "string")
    PluginSetting.create(:plugin_id => @plugin.id, :name => "item_thumbnail_width", :title => "Item Thumbnail Width",  :value => "180", :setting_type => "Plugin", :description => "This is the width(in pixels) of the thumbnails that are generated.", :item_type => "string")
    PluginSetting.create(:plugin_id => @plugin.id, :name => "item_thumbnail_height", :title => "Item Thumbnail Height",  :value => "125", :setting_type => "Plugin", :description => "This is the height(in pixels) of the thumbnails that are generated.", :item_type => "string")           
    PluginSetting.create(:plugin_id => @plugin.id, :name => "resize_item_images", :title => "Resize New Images",  :value => "0", :setting_type => "Plugin", :description => "Enable this if you would like all the images that are added to images resized to a particular size(you can choose the size below).", :item_type => "bool")   
    PluginSetting.create(:plugin_id => @plugin.id, :name => "item_image_width", :title => "New Image Width",  :value => "500", :setting_type => "Plugin", :description => "This is the width you want your images(in pixels) to be automatically resized to. Only used if Resize New Images is turned on.", :item_type => "string")
    PluginSetting.create(:plugin_id => @plugin.id, :name => "item_image_height", :title => "New Image Height",  :value => "500", :setting_type => "Plugin", :description => "This is the height you want your images(in pixels) to be automatically resized to. Only used if Resize New Images is turned on.", :item_type => "string")    
    
    
    # Create New Settings
    Setting.create(:name => "display_popular_items", :title => "Display Most Popular Items",  :value => "1", :setting_type => "Item", :description => "Display the most popular items on the homepage.", :item_type => "bool")
    #Setting.create(:name => "display_num_of_popular_items", :title => "Number of Popular Items to Display",  :value => "3", :setting_type => "Item", :description => "How many popular items to display on the homepage.", :item_type => "string") # deprecated as of 0.3.4            
    Setting.create(:name => "display_item_views", :title => "Display Number of Item Views",  :value => "1", :setting_type => "Item", :description => "Display the number of times an item has been viewed(visible on an item's page).", :item_type => "bool")
    
    # Add a column for number of downloads for files 
    add_column :plugin_files, :downloads, :integer, :default => 0     
    # Add a column for link support for feature values 
    add_column :plugin_feature_values, :url, :string, :default => nil
    # Add a column for descriptions for features 
    add_column :plugin_features, :description, :string, :default => nil
    # Add a column for user's registration ip
    add_column :users, :registered_ip, :string, :default => "0.0.0.0"    
    # Add a column for user's last login ip
    add_column :users, :last_login_ip, :string, :default => "0.0.0.0"        
    # Add a setting that enables/disables user verification emails
    Setting.create(:name => "email_verification_required", :title => "Email Verification Required for New Users",  :value => "0", :setting_type => "User", :description => "If enabled, new users must click on an verification link that is sent to their email account before they can log in.", :item_type => "bool")
     # Add a new page that will show when a user is creating a new item.
    Page.create(:title => "New Item", :description => "This page appears when a User is creating a new item.", :page_type => "system", :content => "")

    
  end

  def self.down
  end
end
