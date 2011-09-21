class PluginReview < ActiveRecord::Base
  include ActionView::Helpers::TextHelper # include text helper for truncate and other options
  acts_as_opal_plugin
  make_voteable
  
  #belongs_to :plugin
  belongs_to :user
  has_many :plugin_review_votes, :dependent => :destroy
  
  before_validation lambda{|o| o.sanitize_content(:review)}
  before_destroy :destroy_votes
   
  scope :with_total_vote_score, lambda{   # computes vote score of reviews by summing all associated plugin_review_vote records(deprecated as of 0.7.4)
    group("plugin_reviews.id").
    joins(:plugin_review_votes).
    select("plugin_reviews.*").
    select("sum(plugin_review_votes.score) as total_vote_score")
  }
  scope :most_votes_first, order("up_votes - down_votes DESC")
  
  validates_presence_of :review_score
  validates_presence_of :record_id, :user_id
  validates_length_of :review, :minimum => 16
  
  attr_accessible :review, :review_score 
  
  def to_s
  	truncate(strip_tags(review), :length => 50)
  end
  
  def validate # custom validations          
    min = PluginReview.get_setting("score_min").to_i
    max = PluginReview.get_setting("score_max").to_i
    errors.add(:review_score, I18n.t("activerecord.errors.messages.range", :min => min, :max => max)) if !(self.review_score.to_i >= min && self.review_score.to_i <= max) 
  end
    
  def validate_on_create
     errors.add(:base, I18n.t("activerecord.errors.messages.items_cannot_add_more", :items => self.class.model_name.human(:count => :other))) if PluginReview.find(:all, :conditions => ["user_id = ? and item_id = ?", self.user_id, self.item_id]).size > 0
     errors.add(:base, I18n.t("activerecord.errors.messages.item_must_be_owner", :item => self.class.model_name.human)) if Setting.get_setting_bool("only_creator_can_review") && self.user_id != self.item.user_id    
  end

  def destroy_votes # destroy make_voteable votes
    for vote in votings
      vote.destroy
    end
  end     
     
end
