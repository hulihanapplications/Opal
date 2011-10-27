class PluginTag < ActiveRecord::Base
  acts_as_opal_plugin

  belongs_to :user

  validates_presence_of :name 
  validates_length_of :name, :minimum => 1
  validates_format_of :name, :with => /^[a-zA-Z0-9][^\.\?&=\s]*$/  # make url safe.
  #validates_uniqueness_of :name, :scope => :item_id

  attr_accessible :name
  
  scope :unique, group(:name)
  scope :category, lambda{|category| items(category.items)} # get tags only involving these items
  scope :records, lambda{|records| where(:item_id => records.collect{|r| r.id})} # get tags only involving these items
  
  def to_s
  	name
  end
  
  def count # get number of tags with same name
    PluginTag.where(:name => name).count
  end
end
