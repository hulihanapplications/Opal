class AddSenderEmailSetting < ActiveRecord::Migration
  def self.up
	    Setting.create(:name => "sender_email",  :value => "noreply@nowhere.com", :setting_type => "System", :item_type => "string")
  end 

  def self.down
  end
end
