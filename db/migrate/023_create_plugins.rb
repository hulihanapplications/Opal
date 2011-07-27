class CreatePlugins < ActiveRecord::Migration
  class Plugin < ActiveRecord::Base ;  end # override model to bypass validations, etc.
  def self.up
    create_table :plugins do |t|
      t.column :name, :string, :nil => false
      t.column :order_number, :integer, :default => 0 # This must be 0 indexed because of each_index in the sorting method 
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically 
      t.column :is_enabled, :string, :limit => 1, :default => "1"
      t.column :is_builtin, :string, :limit => 1, :default => "0" 
      t.timestamps
    end
        
  	# Create Builtin Plugins, plugin.name is not displayed name, it is used for related Plugin Class lookup, ie: "Image" => PluginImage
  	plugin = Plugin.create(:name => "Image", :is_enabled => "1", :is_builtin => "1")
  	plugin = Plugin.create(:name => "Description", :is_enabled => "1", :is_builtin => "1")
  	plugin = Plugin.create(:name => "Feature", :is_enabled => "1", :is_builtin => "1")
  	plugin = Plugin.create(:name => "Link", :is_enabled => "1", :is_builtin => "1")    
  	plugin = Plugin.create(:name => "Review",  :is_enabled => "1", :is_builtin => "1")
  	plugin = Plugin.create(:name => "Comment", :is_enabled => "1", :is_builtin => "1")    
  	plugin = Plugin.create(:name => "File",  :is_enabled => "1", :is_builtin => "1")
  	plugin = Plugin.create(:name => "Tag", :is_enabled => "1", :is_builtin => "1")              
  	plugin = Plugin.create(:name => "Discussion", :order_number => Plugin.next_order_number, :is_enabled => "1", :is_builtin => "1")	    
  end

  def self.down
    drop_table :plugins
  end
end
