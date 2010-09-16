class CreatePluginReviewVotes < ActiveRecord::Migration
  def self.up
    create_table :plugin_review_votes do |t|
      t.integer :plugin_review_id
      t.integer :user_id
      t.integer :score, :default => 0
      t.timestamps
    end
    
    #PluginReviewVote.create(:plugin_review_id => 1, :user_id => 1, :vote => 2)
    #PluginReviewVote.create(:plugin_review_id => 1, :user_id => 2, :vote => -1)
    #PluginReviewVote.sum(:vote, :conditions => ["plugin_review_id = ?", 1])
  end

  def self.down
    drop_table :plugin_review_votes
  end
end
