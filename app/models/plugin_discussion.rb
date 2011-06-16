class PluginDiscussion < ActiveRecord::Base
  acts_as_opal_plugin

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
end
