class CreatePageComments < ActiveRecord::Migration
  def self.up
    create_table :page_comments do |t|
      t.column :page_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.text :comment#  what they have to say
      t.column :anonymous_email, :string, :default => nil
      t.column :anonymous_name, :string, :default => nil      
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.timestamps
    end
  end

  def self.down
    drop_table :page_comments
  end
end
