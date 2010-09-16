class ZeroTwoZeroNewFeatures < ActiveRecord::Migration
  def self.up
    Setting.create(:name => "plugin_list_type", :title => "Plugin List Type",  :value => "tabs_horizontal", :setting_type => "Hidden", :description => "This changes what the Item Object Sections look like on an Item's page.", :item_type => "string") # other choices: tabs-horizontal, tabs-vertical, accordian, fully-displayed
    Setting.create(:name => "allow_item_list_type_changes", :title => "Allow Item List Type Changes from the Public",  :value => "1", :setting_type => "Item", :description => "If enabled, this setting allows anyone(even the public) to change the Item list type that they see when visiting your Opal application. This only affects the visitor's browser.", :item_type => "bool") # let the public change the item list type(via session[:list_type])
    Setting.create(:name => "enable_navlinks", :title => "Enable NavLinks",  :value => "1", :setting_type => "Item", :description => "NavLinks are simple navigation links shown at the top of item and item list pages. They show information about which category an item or category is in, and more.", :item_type => "bool")     
    Setting.create(:name => "allow_private_items", :title => "Allow Private Items",  :value => "1", :setting_type => "Item", :description => "If enabled, users can create private items that aren't visible to the public or other users. Only the owner of the item and admins can see private items. If disabled, all items will become public upon creation.", :item_type => "bool")          
    Setting.create(:name => "let_users_create_items", :title => "Let Users Create Items",  :value => "1", :setting_type => "Item", :description => "If disabled, regular users cannot create items...only admins can.", :item_type => "bool")              
    # add record attributes to fit in anonymous comments.   
    add_column :plugin_comments, :anonymous_email, :string, :default => nil
    add_column :plugin_comments, :anonymous_name, :string, :default => nil

    #comment_plugin = Plugin.find_by_name("Comment")
    #PluginSetting.create(:plugin_id => comment_plugin.id, :name => "allow_anonymous_comments", :title => "Allow Anonymous Comments",  :value => "0", :setting_type => "Item Object", :description => "Allows visitors who don't have an account in your Opal application to leave comments for an Item.", :item_type => "bool")      
    #review_plugin = Plugin.find_by_name("Review")
    #PluginSetting.create(:plugin_id => review_plugin.id, :name => "only_creator_can_review", :title => "Only Item Creator can Review",  :value => "0", :setting_type => "System", :description => "If enabled, only the item's creator and admins are allowed to leave a review for the item.", :item_type => "bool")               
  end

  def self.down
  end
end
