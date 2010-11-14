class ZeroThreeTwo < ActiveRecord::Migration
  def self.up
    # Group IDs for users
    add_column(:users, :group_id, :integer, :default => 2)     
    
    # Create Groups
    public_group = Group.new(:name => "The Public", :description => "People visiting your site that aren't logged in.")
    public_group.is_deletable = "0"
    public_group.save     
    users_group = Group.new(:name => "Regular Users", :description => "Regular Users that have signed up at your site.")
    users_group.is_deletable = "0"
    users_group.save   
    admin_group = Group.new(:name => "Admins", :description => "Supreme Masters. They can access and do anything.")
    admin_group.is_deletable = "0"
    admin_group.save     
    
    # Reset Columns so we can use the new columns we've added
    User.reset_column_information
    
    # Make admin join the admins group
    puts "-- Adding Existing Admins to the new Admins group..."
    admin_users = User.find(:all, :conditions => ["is_admin = '1'"])
    for admin_user in admin_users       
      if admin_user.update_attribute(:group_id, 3)
        puts "\t#{admin_user.username}'s group updated!"
      else 
        puts "\t#{admin_user.username}'s failed updating!"        
      end
    end
    
    # Set plugin permissions for regular users
    for plugin in Plugin.find(:all)
      GroupPluginPermission.create(:group_id => users_group.id, :plugin_id => plugin.id, :can_read => "1") # turn on read permissions      
    end

    # Set plugin permissions for the public
    for plugin in Plugin.find(:all)
      GroupPluginPermission.create(:group_id => public_group.id, :plugin_id => plugin.id, :can_read => "1") # turn on read permissions      
    end   
    
    # Create Opal Version Setting
    Setting.create(:name => "opal_version", :title => "Opal",  :value => "0.3.2", :setting_type => "Hidden", :description => "This is the current version you're running.", :item_type => "string")
    
  end

  def self.down
  end
end
