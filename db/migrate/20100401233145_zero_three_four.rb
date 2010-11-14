class ZeroThreeFour < ActiveRecord::Migration
  def self.up
     # Update Opal Version
    Setting.find_by_name("opal_version").update_attribute(:value, "0.3.4")    
    
    Setting.create(:name => "section_blog", :title => "Blog",  :value => "1", :setting_type => "Section", :description => "Opal's Integrated Blog. If enabled, a <b>blog</b> link will show up in the main menu.", :item_type => "bool")
    Setting.create(:name => "section_about", :title => "About",  :value => "1", :setting_type => "Section", :description => "Opal's About Section. This section is designed to help people learn about your site. It displays public pages(you create), terms of service, and contact tools. If enabled, an <b>about</b> link will show up in the main menu.", :item_type => "bool")
    
    
    # Create Email Notification Settings
    add_column(:user_infos, :notify_of_new_messages, :boolean, :default => true) # notify users of new messages.    
    
    # Create Token to let users recover their password
    add_column(:user_infos, :forgot_password_code, :string)
    

  end

  def self.down
  end
end
