class ZeroSevenThree < ActiveRecord::Migration
  def self.up
    add_column :users, :salt, :string
    add_column :plugin_features, :category_id, :integer
  end

  def self.down
  end
end
