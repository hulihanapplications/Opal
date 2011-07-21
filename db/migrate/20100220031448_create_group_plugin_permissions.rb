class CreateGroupPluginPermissions < ActiveRecord::Migration
  def self.up
    create_table :group_plugin_permissions do |t|
      t.column :group_id, :integer, :nil => false
      t.column :plugin_id, :integer, :nil => false
      # These permissions are for people besides the item's owners.
      t.string :can_create , :limit => 1, :default => "0"      
      t.string :can_read , :limit => 1, :default => "0"
      t.string :can_update, :limit => 1, :default => "0"
      t.string :can_delete, :limit => 1, :default => "0"
      t.string :requires_approval, :limit => 1, :default => "0" # requires approval from owner/admin         
      t.timestamps
    end
    
	# Create Default Group Plugin Permissions
	for plugin in Plugin.all
		GroupPluginPermission.create(:group_id => Group.public.id, :plugin_id => plugin.id, :can_read => "1") unless (plugin.name == "Comment")
		GroupPluginPermission.create(:group_id => Group.user.id, :plugin_id => plugin.id, :can_read => "1")	unless (plugin.name == "Review" || plugin.name == "Comment")					
	end
	
	GroupPluginPermission.create(:group_id => Group.public.id, :plugin_id => Plugin.find_by_name("Comment").id, :can_create => "1", :can_read => "1")
	GroupPluginPermission.create(:group_id => Group.user.id, :plugin_id => Plugin.find_by_name("Comment").id, :can_create => "1", :can_read => "1")
	GroupPluginPermission.create(:group_id => Group.user.id, :plugin_id => Plugin.find_by_name("Review").id, :can_create => "1", :can_read => "1")
  end

  def self.down
    drop_table :group_plugin_permissions
  end
end
