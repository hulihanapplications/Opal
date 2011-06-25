class PluginDiscussionPost < ActiveRecord::Base
  belongs_to :plugin_discussion
  belongs_to :user
  belongs_to :item
  
  default_scope :order => "created_at ASC"
  
  validates_presence_of :post 
end
