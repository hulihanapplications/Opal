class PluginDiscussion < ActiveRecord::Base
  acts_as_opal_plugin
  belongs_to :user
  has_many :plugin_discussion_posts, :dependent => :destroy
   
  default_scope :order => "title ASC"
  
  validates_presence_of :title   
  
  attr_accessible :title, :description 
  
  def to_s 
  	title
  end
end
