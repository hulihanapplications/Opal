class CreateItemStatistics < ActiveRecord::Migration
  def self.up
    create_table :item_statistics do |t|
      t.column :item_id, :integer, :nil => false
      t.column :views, :integer, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :item_statistics
  end
end
