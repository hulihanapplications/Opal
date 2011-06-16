class CreatePluginVideos < ActiveRecord::Migration
  def self.up
    create_table :plugin_videos do |t|
      t.integer :item_id, :nil => false
      t.integer :user_id, :nil => false
      t.string :title
      t.text :description
      t.text  :code
      t.string :is_approved, :limit => 1, :default => "0"
      t.timestamps
    end
  end

  def self.down
    drop_table :plugin_videos
  end
end
