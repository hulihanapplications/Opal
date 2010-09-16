class CreatePluginTags < ActiveRecord::Migration
  def self.up
    create_table :plugin_tags do |t|
      t.column :item_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.integer :parent_id, :default => 0 #  link_url
      t.string :name #  link title Ie: "Download Link"
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
    end
  end

  def self.down
    drop_table :plugin_tags
  end
end
