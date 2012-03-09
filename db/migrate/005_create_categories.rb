class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
     t.column :name, :string
     t.column :category_id, :integer, :default => 0
     #t.column :category_type, :string, :default => ""
     t.column :image_url, :string
     t.column :description, :string, :default => ""
     t.column :created_at, :datetime
     t.column :updated_at, :datetime
    end

  end

  def self.down
    drop_table :categories
  end
end
