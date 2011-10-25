class ZeroSevenFour < ActiveRecord::Migration
  def self.up   
    add_column :items, :preview_type, :string
    add_column :items, :preview_id, :integer 
    add_column :settings, :record_type, :string
    add_column :settings, :record_id, :integer   
    add_column :plugin_reviews, :up_votes, :integer, :default => 0 
    add_column :plugin_reviews, :down_votes, :integer, :default => 0
    add_column :plugin_reviews, :plugin_review_category_id, :integer
    add_column :plugin_comments, :up_votes, :integer, :default => 0 
    add_column :plugin_comments, :down_votes, :integer, :default => 0         
    add_column :plugin_comments, :ancestry, :string
    add_index :plugin_comments, :ancestry
    add_column :categories, :ancestry, :string
    add_index :categories, :ancestry
    add_column :pages, :ancestry, :string
    add_index :pages, :ancestry
    add_column :user_infos, :notify_of_item_changes, :boolean, :default => true         
    add_index :plugin_tags, :name
       
    Setting.create(:name => "default_preview_type",  :value => "PluginImage", :setting_type => "Hidden", :item_type => "string") # when a plugin record is created for an item, its preview will be set to this   
    Setting.create(:name => "host",  :value => "localhost", :setting_type => "System", :item_type => "string")            
    PluginSetting.create(:plugin_id => Plugin.find_by_name("Tag").id, :name => "tag_list_mode", :value => "Cloud", :options => "Cloud, None", :item_type => "option") # when a plugin record is created for an item, its preview will be set to this   

    # convert old votes
    for vote in PluginReviewVote.all
      new_vote = MakeVotable::Voting.new(:voter_id => vote.user_id, :voter_type => "User", :voteable_id => vote.plugin_review_id, :voteable_type => "PluginReview", :up_vote => (vote.score > 0 ? true : false), :down_vote => (vote.score <= 0 ? true : false))
      vote.destroy if new_vote.save
    end
    
  end

  def self.down
    Setting.find_by_name("default_preview_type").destroy if Setting.find_by_name("default_preview_type")
    Setting.find_by_name("host").destroy if Setting.find_by_name("host")
    tag_list_setting = Plugin.find_by_name("Tag") ? PluginSetting.where(:name => "tag_list_mode").where(:plugin_id => Plugin.find_by_name("Tag").id).first : nil  
    tag_list_setting.destroy if tag_list_setting
  	
    remove_column :items, :preview_type
    remove_column :items, :preview_id 
    Item.reset_column_information
    remove_column :settings, :record_type
    remove_column :settings, :record_id   
    Setting.reset_column_information
    remove_column :plugin_reviews, :up_votes
    remove_column :plugin_reviews, :down_votes
    remove_column :plugin_reviews, :plugin_review_category_id  	
    PluginReview.reset_column_information
    remove_column :plugin_comments, :up_votes
    remove_column :plugin_comments, :down_votes
    remove_index :plugin_comments, :ancestry  
    remove_column :plugin_comments, :ancestry      
    PluginComment.reset_column_information         
    remove_index :categories, :ancestry  
    remove_column :categories, :ancestry  
    Category.reset_column_information
    remove_index :pages, :ancestry  
    remove_column :pages, :ancestry
    Page.reset_column_information    
    remove_column :user_infos, :notify_of_item_changes
    UserInfo.reset_column_information            
  end
end
