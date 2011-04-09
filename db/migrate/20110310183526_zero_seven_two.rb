class ZeroSevenTwo < ActiveRecord::Migration
  def self.up
    # Remove old Item Name Settings
    item_name_setting = Setting.find_by_name("item_name")
    item_name_setting ? item_name_setting.destroy : nil
    
    item_name_plural_setting = Setting.find_by_name("item_name_plural")
    item_name_plural_setting ? item_name_plural_setting.destroy : nil
    
    # Authlogic Fields
    add_column :users, :persistence_token, :string
    add_column :users, :perishable_token, :string # optional, Great for authenticating users to reset passwords, confirm their account, etc. 
    add_column :users, :single_access_token, :string # optional, allows single session request for RSS Feeds, etc. ie: www.whatever.com?user_credentials=[single access token]
    #add_column :users, :password_salt, :string, :null => false # optional, but highly recommended - already present(user.password_hash)
    # Authlogic Magic Fields(autoupdated, similar to rails created_at)
    add_column :users, :login_count, :integer, :default => 0
    add_column :users, :failed_login_count,  :integer, :default => 0 
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    remove_column :users, :last_login # will be replaced by last_login_at
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string    
    # add_column :users, :last_login_ip, :string # already present
    
    # Add Log Targeting 
    add_column :logs, :target_type, :string
    add_column :logs, :target_id, :integer
  end

  def self.down
  end
end
