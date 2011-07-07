class ZeroSevenFour < ActiveRecord::Migration
  def self.up
    add_column :items, :preview_class, :string
    add_column :items, :preview_id, :integer 
    
    add_column :plugin_reviews, :plugin_review_category_id, :integer
    Setting.create(:name => "default_preview_class",  :value => "PluginImage", :setting_type => "Hidden", :item_type => "string") # when a plugin record is created for an item, its preview will be set to this

    add_column :plugin_reviews, :up_votes, :integer, :default => 0 
    add_column :plugin_reviews, :down_votes, :integer, :default => 0
    add_column :plugin_comments, :up_votes, :integer, :default => 0 
    add_column :plugin_comments, :down_votes, :integer, :default => 0    

    # convert old votes
    for vote in PluginReviewVote.all
      new_vote = MakeVotable::Voting.new(:voter_id => vote.user_id, :voter_type => "User", :voteable_id => vote.plugin_review_id, :voteable_type => "PluginReview", :up_vote => (vote.score > 0 ? true : false), :down_vote => (vote.score <= 0 ? true : false))
      vote.destroy if new_vote.save
    end
  end

  def self.down
  end
end
