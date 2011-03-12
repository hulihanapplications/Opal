class ZeroSevenTwo < ActiveRecord::Migration
  def self.up
    # Remove old Item Name Settings
    item_name_setting = Setting.find_by_name("item_name")
    item_name_setting ? item_name_setting.destroy : nil
    
    item_name_plural_setting = Setting.find_by_name("item_name_plural")
    item_name_plural_setting ? item_name_plural_setting.destroy : nil
  end

  def self.down
  end
end
