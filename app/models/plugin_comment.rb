class PluginComment < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  acts_as_opal_plugin
  make_voteable
  has_ancestry if PluginComment.table_exists? && column_names.include?("ancestry")

  belongs_to :plugin
  belongs_to :user  
  
  default_scope :order => "created_at DESC"

  before_validation lambda{|o| o.sanitize_content(:comment)}
  before_destroy :destroy_votes  
  after_create :send_reply_notification
  
  validates_presence_of :comment
  #validates_length_of :comment, :maximum => 255, :message => "This comment is too long! It must be 255 characters or less."
  attr_accessible :parent_id, :comment, :anonymous_name, :anonymous_email

  scope :most_votes_first, order("up_votes - down_votes DESC")
  
  def to_s
  	truncate(comment, :length => 20)
  end
  
  def destroy_votes # destroy make_voteable votes
    for vote in votings
      vote.destroy
    end
  end  
  
  def reply? # is this comment a reply to another comment
    !parent_id.blank?
  end
  
  def anonymous? # is this an anonymous comment left by a visitor?
    user_id.blank? || user_id == User.anonymous.id 
  end
  
  
  # send email notification to parent comment owner as long as they're not 
  # the record owner(since they'll get a separate notification) or owner of the comment(self)
  def send_reply_notification
    if reply?
      Emailer.plugin_comment_reply_notification(self).deliver if parent.anonymous? || (parent.user && (parent.user != record.user && parent.user != user && parent.user.user_info.notify_of_item_changes))
    end 
  end
end

