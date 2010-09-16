class AddSettingNewItems < ActiveRecord::Migration
  def self.up
    Setting.create(:name => "display_new_items", :title => "Display New Items",  :value => "1", :setting_type => "Items", :description => "Display new items added on the homepage.", :item_type => "bool")    
    #Setting.create(:name => "display_num_of_new_items", :title => "Number of New Items to Display",  :value => "12", :setting_type => "Public", :description => "How many of the new items to display on the homepage.", :item_type => "string") # deprecated as of 0.3.4        
    Setting.create(:name => "display_help_sections", :title => "Display Help Sections",  :value => "0", :setting_type => "Public", :description => "Shows Help Sections in various parts of your site to help users and admins with Opal.", :item_type => "bool")        
    Setting.create(:name => "list_type", :title => "List Type",  :value => "detailed", :setting_type => "Hidden", :description => "The display format of your items.", :item_type => "string") # choices: detailed, photos, small      
  end

  def self.down
    #Setting.find(:first, :conditions => ["name = ?", "display_new_items"]).destroy
    #Setting.find(:first, :conditions => ["name = ?", "display_num_of_new_items"]).destroy    
  end
end
