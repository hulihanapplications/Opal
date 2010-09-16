class PageComment < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  
  validates_presence_of :comment 
  
  default_scope :order => "created_at DESC"
end
