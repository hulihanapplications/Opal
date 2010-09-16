class PluginDiscussion < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
  has_many :plugin_discussion_posts
   
  after_destroy :destroy_everything

  default_scope :order => "title ASC"
  
  validates_presence_of :title 
  
  def destroy_everything
    for item in self.plugin_discussion_posts
      item.destroy
    end
  end
  
  def is_approved?
     if self.is_approved == "1"
       return true
     else # not approved
       return false
     end
  end

end
