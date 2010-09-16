class CreatePlugins < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.column :name, :string, :nil => false
      t.column :title, :string, :default => "" # The item of the object as it shows on the actual page, so you can change "Bullets" to "Features", etc.
      t.column :description, :string, :default => ""
      t.column :order_number, :integer, :default => 0 # This must be 0 indexed because of each_index in the sorting method 
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically 
      t.column :is_enabled, :string, :limit => 1, :default => "1"
      t.column :is_builtin, :string, :limit => 1, :default => "0" 
      t.timestamps
    end
  end

  def self.down
    drop_table :plugins
  end
end
