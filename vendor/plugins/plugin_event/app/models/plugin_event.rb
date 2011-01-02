class PluginEvent < ActiveRecord::Base
  belongs_to :plugin
  belongs_to :item
  belongs_to :user

  validates_presence_of :title
  
  def self.files # list of this plugin's files, these will be copied automatically into Opal during installed, and deleted during uninstall 
    file_list = Array.new
    file_list << "app/models/plugin_event.rb"
    file_list << "app/controllers/plugin_events_controller.rb"
    file_list << "app/views/plugin_events/"    
    file_list << "app/views/plugin_events/_home.html.erb"
    file_list << "app/views/plugin_events/_list.html.erb"
    file_list << "app/views/plugin_events/_view.html.erb"    
    return file_list  
  end

  def self.install # install this plugin
    # Create Database Structure & Records 
    plugin = Plugin.create(:name => "Event", :title => "Event", :description => "Events happening for an Item.", :is_enabled => "1", :is_builtin => "0")
    if !ActiveRecord::Base.connection.tables.include?("plugin_events") 
      ActiveRecord::Migration.create_table :plugin_events do |t|
       t.column :item_id, :integer, :nil => false
       t.column :user_id, :integer, :nil => false
       t.column :title, :string, :default => ""
       t.column :description, :text, :default => ""
       t.column :date, :datetime # date of event
       t.column :price, :string
       t.column :created_at, :datetime #this will get populated automatically
       t.column :updated_at, :datetime #this will get populated automatically
       t.column :is_approved, :string, :default => "0", :limit => 1     
      end
    end 
    
    # Create Plugin Settings
    PluginSetting.create(:plugin_id => plugin.id, :name => "display_upcoming_events", :title => "Display Upcoming Events on Homepage",  :value => "1", :setting_type => "System", :description => "Display Upcoming Events on the homepage.", :item_type => "bool")    
    
    return true
  rescue
    return false
  end 
  
  def self.uninstall # uninstall this plugin
    # Delete Database Structure & Records     
    Plugin.find_by_name("Event").destroy
    ActiveRecord::Migration.drop_table :plugin_events if ActiveRecord::Base.connection.tables.include?("plugin_events") # drop table if it exists
    return true
  end
  
  
  def is_approved?
     if self.is_approved == "1"
       return true
     else # not approved
       return false
     end
  end  
end