class CreateUserMessages < ActiveRecord::Migration
  def self.up
    create_table :user_messages do |t|
      t.column :message, :text
      t.column :user_id, :integer, :nil => false # who the message is for
      t.column :from_user_id, :integer, :nil => false # who the message is from
      t.column :reply_to_message_id, :integer, :default => 0 
      t.column :is_read, :string, :limit => 1, :default => "0"
      t.column :is_deletables, :string, :limit => 1, :default => "1"
      t.column :is_replied_to, :string, :limit => 1, :default => "0"
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically 
    end
  end

  def self.down
    drop_table :user_messages
  end
end
