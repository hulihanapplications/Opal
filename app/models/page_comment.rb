#
# The PageComment model has been deprecated as of Opal 0.8.0
#

class PageComment < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  
  validates_presence_of :comment 
  
  default_scope :order => "created_at DESC"
end
