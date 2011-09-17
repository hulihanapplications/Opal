class AddVideoUploads < ActiveRecord::Migration
  def up
    add_column :plugin_videos, :video, :string
  end

  def down
    remove_column :plugin_videos, :video    
  end
end
