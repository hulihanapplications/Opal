class PluginReview < ActiveRecord::Base
  belongs_to :plugin
  belongs_to :item
  belongs_to :user
  has_many :plugin_review_votes
  
  before_destroy :delete_everything
   validates_presence_of :review_score, :message => "You forgot to select a score!"
   #validates_length_of :review, :minimum => 10, :message => "This review is too short! It must have at least 10 characters."
   #validates_length_of :review, :maximum => 255, :message => "This review is too long! It must be 255 characters or less."

  def delete_everything
    for item in self.plugin_review_votes # delete all votes
      item.destroy
    end
  end

  def validate # custom validations
    # errors.add ""
  end
  
  def can_user_vote?(user) # check if user voted or not
    vote = PluginReviewVote.find(:first, :conditions => ["plugin_review_id = ? and user_id = ?", self.id, user.id])
    if vote || self.user_id == user.id # if they've voted or they created the review
      return false
    else 
      return true 
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
