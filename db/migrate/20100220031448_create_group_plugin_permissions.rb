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
  end

  def self.down
    drop_table :group_plugin_permissions
  end
end
