class ZeroSevenFour < ActiveRecord::Migration
  def self.up
    add_column :items, :preview_class, :string
    add_column :items, :preview_id, :integer 
    
    add_column :plugin_reviews, :plugin_review_category_id, :integer
  end

  def self.down
  end
end
