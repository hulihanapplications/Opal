class CreatePluginReviews < ActiveRecord::Migration
  def self.up
    create_table :plugin_reviews do |t|
      t.column :item_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.float :review_score, :default => 0 # 0...5 or whatever
      t.text :review # what they have to say
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.integer :useful_score, :default => 0 # is this useful? 
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
      t.column :vote_score, :integer, :default => 0
    end
  end

  def self.down
    drop_table :plugin_reviews
  end
end
