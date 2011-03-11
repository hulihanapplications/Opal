class CreateUserMessages < ActiveRecord::Migration
  def self.up
    create_table :user_messages do |t|
      t.column :message, :text
      t.column :user_id, :integer, :nil => false # who the message is for
      t.column :from_user_id, :integer, :nil => false # who the message is from
      t.column :to_user_id, :integer, :default => nil
      t.column :reply_to_message_id, :integer, :default => 0 
      t.column :is_read, :string, :limit => 1, :default => "0"
      t.column :is_deletable, :boolean, :default => true
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically 
    end
  end

  def self.down
    drop_table :user_messages
  end
end
