class ZeroFourOne < ActiveRecord::Migration
  def self.up
    Setting.find_by_name("opal_version").update_attribute(:value, "0.4.1") # Update Version

    # Let Certain Groups Create Certain plugins by default
    public_group = Group.find(1)
    users_group = Group.find(2)
    
    GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", public_group.id, Plugin.find_by_name("Comment").id]).update_attribute(:can_create, "1")  

    GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", users_group.id, Plugin.find_by_name("Comment").id]).update_attribute(:can_create, "1")  
    GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", users_group.id, Plugin.find_by_name("Review").id]).update_attribute(:can_create, "1")  


  
    
          
  end

  def self.down
  end
end
