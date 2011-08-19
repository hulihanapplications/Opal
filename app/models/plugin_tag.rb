class PluginTag < ActiveRecord::Base
  acts_as_opal_plugin

  belongs_to :plugin
  belongs_to :item
  belongs_to :user

  #before_create :shrink_name

  validates_presence_of :name 
  validates_length_of :name, :minimum => 1
  validates_format_of :name, :with => /^[a-zA-Z0-9][^\.\?&=\s]*$/  # make url safe.
  validates_uniqueness_of :name, :scope => :item_id

  scope :unique, group(:name)
  scope :category, lambda{|category| items(category.items)} # get tags only involving these items
  scope :items, lambda{|items| where(:item_id => items.collect{|item| item.id})} # get tags only involving these items
  
  def to_s
  	name
  end
  
  def shrink_name
    self.name = name.downcase 
  end
  
  def count # get number of tags with same name
    PluginTag.where(:name => name).count
  end
end
