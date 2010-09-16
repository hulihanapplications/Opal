class CreatePluginDiscussionPosts < ActiveRecord::Migration
  def self.up
    create_table :plugin_discussion_posts do |t|
      t.integer :plugin_discussion_id
      t.integer :user_id      
      t.integer :item_id 
      t.text    :post
      t.string  :is_sticky, :limit => 1, :default => "1"      
      t.string  :is_enabled, :limit => 1, :default => "0"                   
      t.timestamps
    end
  end

  def self.down
    drop_table :plugin_discussion_posts
  end
end
