class ZeroFiveZero < ActiveRecord::Migration
  def self.up
    Setting.find_by_name("opal_version").update_attribute(:value, "0.5.0") # Update Version
    
    # Make pages publishable
      add_column :pages, :published, :bool, :default => true

    # Add Min & Max values for features
    add_column :plugin_features, :min, :float, :default => nil
    add_column :plugin_features, :max, :float, :default => nil
    
    # Add a dedicated column for recent views for an item, which will get reset after a period of time
    add_column :items, :recent_views, :integer, :default => 0     
 
    # Move views attribute from item_statistics to item
      add_column :items, :views, :integer, :default => 0     
      Item.reset_column_information # reset column caching so we can use new attribute     
      puts "\tUpdating Item Views..."    
      for item in Item.find(:all)
        if item.update_attribute(:views, item.item_statistic.views)
          puts "\t\tUpdated: #{item.name}"
        end
      end    
      remove_column :item_statistics, :views # remove views column from item statistics
    
    # Make Features Listable(That show up in Item Lists)
     add_column :plugin_features, :listed, :bool, :default => true

    # Create Email Footer Page
    Page.create(:title => "Email Footer", :description => "This appears at the bottom of any automated email.", :page_type => "system", :content => "This is an automated email sent to you by #{Setting.get_setting("site_title")}. Please do not reply.")
    
    # Create New Option Type Setting, delimited by comma,
    add_column :settings, :options, :string, :default => nil
    Setting.reset_column_information
    add_column :plugin_settings, :options, :string, :default => nil
    PluginSetting.reset_column_information
             
    # Create Vote Score field for Reviews
    add_column :plugin_reviews, :vote_score, :integer, :default => 0
    
    # Create Different Review Types and Min/Max Scoring
    review_plugin = Plugin.find_by_name("Review")
    PluginSetting.create(:plugin_id => review_plugin.id, :name => "review_type",  :title => "Review Type", :value => "Stars", :description => "This determines the type of scoring that used for items.", :item_type => "option", :options => "Stars, Slider, Number")
    PluginSetting.create(:plugin_id => review_plugin.id, :name => "score_min",  :title => "Minimum Score", :value => "0", :description => "The minimum value that can be used in review scores. This is not used in star ratings.", :item_type => "string")
    PluginSetting.create(:plugin_id => review_plugin.id, :name => "score_max",  :title => "Maximum Score", :value => "5", :description => "The maximum value that can be used in review scores.", :item_type => "string")    
    
  end

  def self.down
  end
end
