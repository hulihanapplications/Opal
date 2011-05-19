class ZeroSevenThree < ActiveRecord::Migration
  def self.up
    add_column :users, :salt, :string    
  end

  def self.down
  end
end
