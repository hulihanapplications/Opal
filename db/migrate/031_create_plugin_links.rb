class CreatePluginLinks < ActiveRecord::Migration
  def self.up
    create_table :plugin_links do |t|
      t.column :item_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.string :title#  link title Ie: "Download Link"
      t.string :url#  link_url
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
    end
  end

  def self.down
    drop_table :plugin_links
  end
end
