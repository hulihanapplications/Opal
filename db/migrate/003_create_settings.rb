class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.column :name, :string
      t.column :title, :string
      t.column :setting_type, :string
      t.column :value, :string
      t.column :description, :string
      t.column :item_type, :string
    end
  end

  def self.down
    drop_table :settings
  end
end
 