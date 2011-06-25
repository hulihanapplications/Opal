class PluginReview < ActiveRecord::Base
  acts_as_opal_plugin
  
  #belongs_to :plugin
  belongs_to :item
  belongs_to :user
  has_many :plugin_review_votes, :dependent => :destroy
  
  scope :with_total_vote_score, lambda{   # computes vote score of reviews by summing all associated plugin_review_vote records
    group("plugin_reviews.id").
    joins(:plugin_review_votes).
    select("plugin_reviews.*").
    select("sum(plugin_review_votes.score) as total_vote_score")
  }
  scope :approved, where("is_approved = ?", "1")
  scope :for_item, lambda{|item| where("item_id = ?", item.id)}
  scope :newest_first, order("created_at DESC")

  
  validates_presence_of :review_score
  validates_presence_of :item_id, :user_id
  #validates_length_of :review, :minimum => 10, :message => "This review is too short! It must have at least 10 characters."
  #validates_length_of :review, :maximum => 255, :message => "This review is too long! It must be 255 characters or less."
  
  def validate # custom validations
    @setting = Hash.new
    @setting[:review_type] = PluginReview.get_setting("review_type")
    @setting[:score_min] = PluginReview.get_setting("score_min").to_i     
    @setting[:score_max] = PluginReview.get_setting("score_max").to_i   
           
    errors.add(:review_score, I18n.t("activerecord.errors.messages.range", :min => @setting[:score_min], :max => @setting[:score_max])) if !(self.review_score >=  @setting[:score_min] && self.review_score <= @setting[:score_max]) 
  end
  
  
  def validate_on_create
     errors.add(:base, I18n.t("activerecord.errors.messages.items_cannot_add_more", :items => self.class.model_name.human(:count => :other))) if PluginReview.find(:all, :conditions => ["user_id = ? and item_id = ?", self.user_id, self.item_id]).size > 0
     errors.add(:base, I18n.t("activerecord.errors.messages.item_must_be_owner", :item => self.class.model_name.human)) if Setting.get_setting_bool("only_creator_can_review") && self.user_id != self.item.user_id    
  end
  
  def can_user_vote?(user) # check if user voted or not
    vote = PluginReviewVote.find(:first, :conditions => ["plugin_review_id = ? and user_id = ?", self.id, user.id])
    if vote || self.user_id == user.id # if they've voted or they created the review
      return false
    else 
      return true 
    end    
  end
     
end
