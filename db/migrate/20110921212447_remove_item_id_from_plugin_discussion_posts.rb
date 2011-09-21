class RemoveItemIdFromPluginDiscussionPosts < ActiveRecord::Migration
  def up
    remove_column :plugin_discussion_posts, :item_id
  end

  def down
    add_column :plugin_discussion_posts, :item_id, :integer    
  end
end
