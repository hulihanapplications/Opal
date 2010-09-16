class ZeroFourZero < ActiveRecord::Migration
  def self.up
   # Update Opal Version
   Setting.find_by_name("opal_version").update_attribute(:value, "0.4.0")    
   Setting.create(:name => "new_user_notification",  :title => "Notify Admins of New Users", :value => "1", :setting_type => "User", :description => "If enabled, all admins will be sent an email when a new user registers.", :item_type => "bool")
   Setting.create(:name => "new_item_notification",  :title => "Notify Admins of New Items", :value => "1", :setting_type => "Item", :description => "If enabled, all admins will be sent an email when a new item is created.", :item_type => "bool")
   Setting.create(:name => "display_featured_items", :title => "Display Featured Items",  :value => "1", :setting_type => "Item", :description => "Display featured items on the homepage.", :item_type => "bool")    
   
   # Create Flag for Featured Items
   add_column(:items, :featured, :bool, :default => false)   
   Item.reset_column_information
   
   # Create to_user_id column for UserMessages for Easier Message Duplication
   add_column(:user_messages, :to_user_id, :integer, :default => nil)   
   UserMessage.reset_column_information
   
   # Update existing messages
   puts "\tUpdating User Messages..."
   for message in UserMessage.find(:all)
     message.update_attribute(:to_user_id, message.user_id)
     puts "\t\tUpdated Message: #{message.id}"
   end
 
         
   # Remove is_replied_to flag from messages
   remove_column(:user_messages, :is_replied_to)   
      
   # Fix DB Typo for UserMessage.is_deletable
   remove_column(:user_messages, :is_deletables)
   add_column(:user_messages, :is_deletable, :bool, :default => true)   
   
   # Feature An Example Item
   Item.find(:first).update_attribute(:featured, true)
  end

  def self.down
  end
end
