class AddVideoToPluginVideos < ActiveRecord::Migration
  def change
    add_column :plugin_videos, :video, :string
  end
end
