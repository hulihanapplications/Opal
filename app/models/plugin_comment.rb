class PluginComment < ActiveRecord::Base
  acts_as_opal_plugin
  make_voteable
  has_ancestry if PluginComment.table_exists? && column_names.include?("ancestry")

  belongs_to :plugin
  belongs_to :item
  belongs_to :user  
  
  default_scope :order => "created_at DESC"

  before_destroy :destroy_votes  
  
  validates_presence_of :comment
  #validates_length_of :comment, :maximum => 255, :message => "This comment is too long! It must be 255 characters or less."
  attr_protected :user_id, :item_id
  
  def destroy_votes # destroy make_voteable votes
    for vote in votings
      vote.destroy
    end
  end  
end
