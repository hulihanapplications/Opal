class ZeroThreeOne < ActiveRecord::Migration
  def self.up
    # New File Settings
    @plugin = Plugin.find_by_name("File")
    PluginSetting.create(:plugin_id => @plugin.id, :name => "login_required_for_download", :title => "Require Login For Download",  :value => "0", :setting_type => "System", :description => "If enabled, only users who are logged in can download files. Visitors cannot download anything.", :item_type => "bool")
    PluginSetting.create(:plugin_id => @plugin.id, :name => "log_downloads", :title => "Log Downloads",  :value => "0", :setting_type => "System", :description => "Log all downloads in the Item's activity log.", :item_type => "bool")
    
    # New System Settings
    Setting.create(:name => "allow_page_comments", :title => "Allow Page Comments",  :value => "1", :setting_type => "Public", :description => "If enabled, people can leave comments for pages.", :item_type => "bool")
    Setting.create(:name => "allow_public_access", :title => "Allow Public Access",  :value => "1", :setting_type => "System", :description => "If disabled, users must log in to access the site or any items. If enabled, anyone can view the site and items normally.", :item_type => "bool")
            
    # Create Discussion Plugin
    Plugin.create(:name => "Discussion", :title => "Discussion",  :order_number => Plugin.next_order_number, :description => "Allows multiple people to have discussions about an item.", :is_enabled => "1", :is_builtin => "1")
       
    # Create Sample Discussion
    discussion = PluginDiscussion.new(:item_id => 1, :user_id => 1, :title => "Test Discussion", :description => "This is a test discussion. Feel free to delete this.")
    discussion.is_approved = "1"
    discussion.save

    discussion_post = PluginDiscussionPost.create(:item_id => 1, :user_id => 1, :plugin_discussion_id => discussion.id, :post => "This is a test post.")
    
    # Create a new Log
    Log.create(:log => "Opal installed!", :log_type => "system")
    
    # Create New User Info Atttribute
    add_column(:user_infos, :location, :string, :default => "") # add location attribute


       
  end

  def self.down
  end
end
