class Item < ActiveRecord::Base
  has_one :item_statistic
  belongs_to :user
  belongs_to :category
  
  has_many :plugin_images
  has_many :plugin_descriptions
  has_many :plugin_feature_values
  has_many :plugin_comments
  has_many :plugin_reviews
  has_many :plugin_links
  has_many :plugin_tags
  has_many :plugin_files
  has_one :item_statistic
  has_many :logs
  
  validates_presence_of :name
  
  after_create :create_everything
  after_destroy :destroy_everything
  
  attr_protected :user_id, :is_approved, :featured
  
  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with regular integer id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{name.gsub(/[^a-z0-9]+/i, '-')}" 
  end


  
  def create_everything
    # Create Item Statistic Record
    ItemStatistic.create(:item_id => self.id)
    
    
    # Make Images Folder
    images_path = "#{RAILS_ROOT}/public/images/item_images/#{self.id}"
    FileUtils.mkdir_p(images_path) if !File.exist?(images_path) # create the folder if it doesn't exist

    # Make Images Folder
    files_path = "#{RAILS_ROOT}/files/item_files/#{self.id}"
    FileUtils.mkdir_p(files_path) if !File.exist?(files_path) # create the folder if it doesn't exist
  end

  def destroy_everything
    # Destroy Statistics
    for stat in ItemStatistic.find(:all, :conditions => ["item_id = ?", self.id])
      stat.destroy
    end


    # Destroy Images
    plugins = PluginImage.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end

    # Destroy Description
    plugins = PluginDescription.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end
    
    # Destroy Feature Values
    plugins = PluginFeatureValue.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end
    
    # Destroy Reviews
    plugins = PluginReview.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end    
    
    # Destroy Comments
    plugins = PluginComment.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end
    
    # Destroy Links
    plugins = PluginLink.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end
    
    # Destroy Tags
    plugins = PluginTag.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end
    
    # Destroy Files
    plugins = PluginFile.find(:all, :conditions => ["item_id = ?", self.id])
    for item in plugins
      item.destroy
    end

    # Destroy Discussions
    discussions = PluginDiscussion.find(:all, :conditions => ["item_id = ?", self.id])
    for item in discussions
      item.destroy
    end
    
    # Remove Images Folder
    images_path = "#{RAILS_ROOT}/public/images/item_images/#{self.id}"
    FileUtils.rm_rf(images_path) if File.exist?(images_path) # remove the folder if it exists 
    
    # Remove Files Folder
    files_path = "#{RAILS_ROOT}/files/item_files/#{self.id}"
    FileUtils.rm_rf(files_path) if File.exist?(files_path) # remove the folder if it exists 
    
    #require "#{RAILS_ROOT}/print_id.rb"
  end
  
  
  def features_never_used
    features = PluginFeature.find(:all)
    features_container = Array.new
    for feature in features
      # Check if a value has been set for this feature & item
      feature_value = PluginFeatureValue.find(:first, :conditions => ["item_id =? and plugin_feature_id = ?", self.id, feature.id])
      if !feature_value # if there is no value, add feature to container 
        features_container << feature
      end
    end
    return features_container
  end
  
  def is_viewable_for_user?(user) # Can the current user see this item?
    if user.is_admin == "1" || self.user_id == user.id # User is an admin, or the user that created the item. Item owners can always see their item, but no one else can, if not allowed.
      return true
    else # not an admin or user that created item.
        if self.is_public == "1" && self.is_approved == "1"
          return true
        elsif (self.is_public == "0" && self.is_approved == "1") # It's not public, but is approved 
          return false
        else # not public or viewable
          return false
        end
    end
  end
  
  def is_editable_for_user?(user) # can the user edit this item?
     if (self.is_user_owner?(user)  || user.is_admin == "1") && user.id != 0 # Yes, the item belongs to the user
       return true
     else # The item does not belong to the user.
       return false
     end
  end
  
  def is_deletable_for_user?(user) # Can the current user see this item?
    if user.is_admin == "1" # User is an admin
      return true
    else # not an admin
      setting = Setting.find(:first, :conditions => ["name = ?", "users_can_delete_items"], :limit => 1 ) # get setting for users to delete items
      if setting.value == "1" && self.user_id == user.id # check if user that owns this item and users are allowed to delete items
        return true
      else # either not owner or users can't delete items
        return false
      end
    end
  end
  
  def is_approved?
     if self.is_approved == "1"
       return true
     else # The item is not approved
       return false
     end
  end

  def is_public?
     if self.is_public == "1"
       return true
     else # The item is not approved
       return false
     end
  end
 
  def is_user_owner?(user)
     if self.user_id == user.id # is this user the owner?
       return true
     else # not the owner
       return false
     end    
  end
  
  def self.popular_items # get the most popular items
    return Item.find(:all, :order => "views DESC", :limit => 10)
  end 

  def self.featured_items # get featured items
    return Item.find(:all, :conditions => ["featured = true and is_approved = '1' and is_public = '1'"], :order => "created_at DESC")
  end 
  
  def is_new? # has the item been recently added?
    max_hours = 72 # the item must be added within the last x hours to be considered new 
    return ((Time.now - self.created_at) / 3600) < max_hours # convert secs to hours 
  end

  def self.sort_conditions(options = {}) # get sanitized sort conditions for use in find
  end

  def self.sort_order(options = {}) # get sanitized sort order for use in find
    options[:by] ||= "Date Added"
    options[:direction] ||= "desc"     
    
    # translate to protect against injection 
    translation = Hash.new # create a hash that indexes items by possible user input, but the value of the item is the actual value we'll use.    
    translation[:by] = Hash.new 
    translation[:by]["Date Added"] = "created_at"
    translation[:by]["Name"] = "name"
    translation[:by]["Popularity"] = "views"
    
    translation[:direction] = Hash.new
    translation[:direction]["asc"] = "ASC"
    translation[:direction]["desc"] = "DESC"
    
    return translation[:by][options[:by]] + " " + translation[:direction][options[:direction]] 
  end
end
