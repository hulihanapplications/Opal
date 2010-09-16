class PluginComment < ActiveRecord::Base
  belongs_to :plugin
  belongs_to :item
  belongs_to :user
  
  default_scope :order => "created_at DESC"
  
  validates_presence_of :comment, :message => "You didn't really enter in a comment."
  #validates_length_of :comment, :maximum => 255, :message => "This comment is too long! It must be 255 characters or less."
  attr_protected :user_id, :item_id

  
  def is_approved?
     if self.is_approved == "1"
       return true
     else # not approved
       return false
     end
  end  
end
