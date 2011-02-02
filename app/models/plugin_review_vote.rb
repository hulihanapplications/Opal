class PluginReviewVote < ActiveRecord::Base
  belongs_to :plugin_review
  belongs_to :user
  
  validates_uniqueness_of :plugin_review_id, :scope => :user_id, :message => "You already voted!"  
end
