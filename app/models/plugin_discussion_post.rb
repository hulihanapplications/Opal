class PluginDiscussionPost < ActiveRecord::Base
  belongs_to :plugin_discussion
  belongs_to :user
  
  default_scope :order => "created_at DESC"
  
  validates_presence_of :post 
end
