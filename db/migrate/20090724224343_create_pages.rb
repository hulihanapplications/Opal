# Pages are used for non-item content.
class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :page_id, :default => 0 # parent page id
      t.integer :user_id, :default => nil # user who added page
      t.column :name, :string, :default => nil
      t.string :title, :default => "" # title of the page
      t.string :description, :default => ""      
      t.string :page_type, :default => "public" # public, system(title & description non-editable)
      t.text :content 
      t.column :deletable, :boolean, :default => true # if page can be deleted    
      t.column :title_editable, :boolean, :default => true # if title can be edited
      t.column :description_editable, :boolean, :default => true # if description can be edited    
      t.column :content_editable, :boolean, :default => true # if content can be edited      
      t.column :published, :boolean, :default => true   
      t.column :locked, :boolean, :default => false 
      t.column :order_number, :integer      
      t.column :display_in_menu, :boolean, :default => true # display in menu    
      t.column :redirect, :boolean, :default => false # redirect this page?  
      t.column :redirect_url, :string, :default => nil # if they want to redirect this to another url
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
