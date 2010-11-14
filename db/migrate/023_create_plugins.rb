class CreatePlugins < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.column :name, :string, :nil => false
      t.column :title, :string, :default => "" # The item of the object as it shows on the actual page, so you can change "Bullets" to "Features", etc.
      t.column :description, :string, :default => ""
      t.column :order_number, :integer, :default => 0 # This must be 0 indexed because of each_index in the sorting method 
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically 
      t.column :is_enabled, :string, :limit => 1, :default => "1"
      t.column :is_builtin, :string, :limit => 1, :default => "0" 
      t.timestamps
    end

    # Create Plugins
    Plugin.create(:name => "Image", :title => "Image", :description => "Images for Items.", :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Description", :title => "Description", :description => "Large Text Descriptions For Items.",   :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Feature", :title => "Feature", :description => "These are atttributes that an several items might have. For example: a house would have a feature called <b>price</b>.", :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Link", :title => "Link", :description => "A link for an item. This can be a link to a page for more information about the item, a website, or a file location.", :is_enabled => "1", :is_builtin => "1")    
    Plugin.create(:name => "Review", :title => "Review", :description => "Item Reviews from Users. Reviews have scores that are tallied up to rate the value an item.",  :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Comment", :title => "Comment", :description => "Item Comments from Users. Comments are just notes about the item.", :is_enabled => "1", :is_builtin => "1")    
    Plugin.create(:name => "File", :title => "File", :description => "Files uploaded for a particular item. Useful for Software, PDFs, Images, etc.", :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Tag", :title => "Tag", :description => "Tags/Labels for an Item. This is another way to organize items besides by categories. All tags in the System are grouped together. You can add as many as you want.", :is_enabled => "1", :is_builtin => "1")          
  end

  def self.down
    drop_table :plugins
  end
end
