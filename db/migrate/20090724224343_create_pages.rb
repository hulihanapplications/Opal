# Pages are used for non-item content.
class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :page_id, :default => 0 # parent page id
      t.integer :user_id, :default => nil # user who added page
      t.string :title, :default => "" # title of the page
      t.string :description, :default => ""      
      t.string :page_type, :default => "public" # public, system(title & description non-editable)
      t.text :content 
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
