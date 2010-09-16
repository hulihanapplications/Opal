class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :name, :string, :nil => false
      t.column :description, :string, :nil => false
      t.string :is_deletable, :limit => 1, :default => "1" # can this group be deleted?      
      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
