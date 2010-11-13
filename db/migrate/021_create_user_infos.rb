class CreateUserInfos < ActiveRecord::Migration
  # This contains all non-critical information for users(address, names, etc.)
  def self.up
    create_table :user_infos do |t|
      t.column :user_id, :integer, :nil => false
      t.column :street_address, :string, :default => ""
      t.column :city, :string, :default => ""
      t.column :state, :string, :default => ""
      t.column :zip, :string, :default => ""
      t.column :country, :string, :default => ""
      t.column :description, :text
      t.column :interests, :string, :default => ""
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically 
     end
  end 

  def self.down
    drop_table :user_infos
  end
end
