class CreatePluginSettings < ActiveRecord::Migration
  def self.up
    create_table :plugin_settings do |t|
      t.column :plugin_id, :integer
      t.column :name, :string 
      t.column :setting_type, :string
      t.column :value, :string
      t.column :item_type, :string
      t.timestamps
      t.column :options, :string, :default => nil
    end
  end

  def self.down
    drop_table :plugin_settings
  end
end
