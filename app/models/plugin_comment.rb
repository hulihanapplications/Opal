class PluginComment < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  acts_as_opal_plugin
  make_voteable
  has_ancestry if PluginComment.table_exists? && column_names.include?("ancestry")

  belongs_to :plugin
  belongs_to :item
  belongs_to :user  
  
  default_scope :order => "created_at DESC"

  before_destroy :destroy_votes  
  #after_create :send_notification
  
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
end

