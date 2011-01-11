class CreatePluginComments < ActiveRecord::Migration
  def self.up
    create_table :plugin_comments do |t|
      t.column :item_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.text :comment #  what they have to say
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
      t.column :anonymous_email, :string, :default => nil
      t.column :anonymous_name, :string, :default => nil
    end
  end

  def self.down
    drop_table :plugin_comments
  end
end
