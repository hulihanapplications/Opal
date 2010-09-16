class PluginEvent < ActiveRecord::Base
  belongs_to :plugin
  belongs_to :item
  belongs_to :user

  validates_presence_of :title

  def self.install
    ActiveRecord::Migration.create_table :plugin_events do |t|
     t.column :item_id, :integer, :nil => false
     t.column :user_id, :integer, :nil => false
     t.column :title, :string, :default => ""
     t.column :description, :text, :default => ""
     t.column :date, :datetime # date of event
     t.column :price, :string
     t.column :created_at, :datetime#this will get populated automatically
     t.column :updated_at, :datetime#this will get populated automatically
     t.column :is_approved, :string, :default => "0", :limit => 1     
    end
  end 
  
  def self.uninstall
    ActiveRecord::Migration.drop_table :plugin_events
  end
end