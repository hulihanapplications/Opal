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
    # Delete Fracture Main Logo if it exists
    file = File.join(RAILS_ROOT, "public", "themes", "fracture", "images", "logo.png")
    if File.exists?(file)
      File.delete(file) 
      puts "\tDeleted: #{file}"
    end
    
    drop_table :settings
  end
end
 