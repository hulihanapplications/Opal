class ZeroFourOne < ActiveRecord::Migration
  def self.up
    Setting.find_by_name("opal_version").update_attribute(:value, "0.4.1") # Update Version


    
          
  end

  def self.down
  end
end
