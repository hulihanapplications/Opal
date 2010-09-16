class CreatePluginDiscussions < ActiveRecord::Migration
  def self.up
    create_table :plugin_discussions do |t|
      t.integer :item_id
      t.integer :user_id      
      t.string :title
      t.string :description
      t.string :is_sticky, :limit => 1, :default => "0"
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.string :is_closed, :limit => 1, :default => "0" # if closed, no new posts can be added.      
      t.timestamps
    end
  end

  def self.down
    drop_table :plugin_discussions
  end
end
