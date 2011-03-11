class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column :name, :string, :nil => false
      t.column :description, :string, :nil => false
      t.column :user_id, :integer, :nil => false
      t.column :category_id, :integer, :default => 1
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.string :is_public, :limit => 1, :default => "1" 
      t.column :created_at, :datetime # this will get populated automatically  
      t.column :updated_at, :datetime # this will get populated automatically 
      t.column :featured, :boolean, :default => false
      t.column :views, :integer, :default => 0     
      t.column :recent_views, :integer, :default => 0  
      t.column :locked, :boolean, :default => false   
    end
  end

  def self.down
    drop_table :items
  end
end
