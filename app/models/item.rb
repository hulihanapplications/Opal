class Item < ActiveRecord::Base
  has_one :item_statistic 
  belongs_to :user
  belongs_to :category
  has_many :plugin_comments, :dependent => :destroy, :as => :record
  has_many :plugin_descriptions, :dependent => :destroy, :as => :record
  has_many :plugin_discussions, :dependent => :destroy, :as => :record
  has_many :plugin_feature_values, :dependent => :destroy, :as => :record
  has_many :plugin_files, :dependent => :destroy, :as => :record
  has_many :plugin_images, :dependent => :destroy, :as => :record
  has_many :plugin_links, :dependent => :destroy, :as => :record
  has_many :plugin_reviews, :dependent => :destroy, :as => :record
  has_many :plugin_tags, :dependent => :destroy, :as => :record
  has_many :plugin_videos, :dependent => :destroy, :as => :record
  has_many :logs, :as => :target
  belongs_to :preview, :polymorphic => true
  validates_presence_of :name, :user_id 
  
  validate :validate_remaining_items, :on => :create
  after_create :create_everything  
  after_create :notify
  after_destroy :destroy_everything
  after_save :save_tags
  
  attr_accessor :tags 
  attr_protected :user_id, :is_approved, :featured, :locked

  scope :featured, where(:featured => true)
  scope :public, where("is_public = ?", "1")
  scope :approved, where("is_approved = ?", "1")
  scope :popular, order("recent_views DESC")
 
  
  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with regular integer id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{name.parameterize}" 
  end
  
  def to_s
    name
  end
  
  def create_everything   
  end

  def destroy_everything    
    # Remove Images Folder
    images_path = "#{Rails.root.to_s}/public/images/item_images/#{self.id}"
    FileUtils.rm_rf(images_path) if File.exist?(images_path) # remove the folder if it exists 
    
    # Remove Files Folder
    files_path = "#{Rails.root.to_s}/files/item_files/#{self.id}"
    FileUtils.rm_rf(files_path) if File.exist?(files_path) # remove the folder if it exists 
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
  
  def is_approved?
    self.is_approved == "1"
  end

  def is_public?
    self.is_public == "1"
  end
  
  def self.sort_order(options = {}) # get sanitized sort order for use in find
    options[:by] ||= Item.human_attribute_name(:created_at)
    options[:direction] ||= "desc"     
    
    # translate to protect against injection 
    translation = Hash.new # create a hash that indexes items by possible user input, but the value of the item is the actual value we'll use.    
    translation[:by] = Hash.new 
    translation[:by][Item.human_attribute_name(:created_at)] = "created_at"
    translation[:by][Item.human_attribute_name(:name)] = "name"
    translation[:by][Item.human_attribute_name(:views)] = "views"
    
    translation[:direction] = Hash.new
    translation[:direction]["asc"] = "ASC"
    translation[:direction]["desc"] = "DESC"
    
    return translation[:by][options[:by]] + " " + translation[:direction][options[:direction]] 
  end
  
  def main_image # get the main image for this item
   return PluginImage.find(:first, :conditions => ["item_id = ?", self.id], :order => "created_at ASC")
 end


 def tag_list
     tag_array = Array.new
     for tag in self.plugin_tags
      tag_array << tag.name
     end   
     return tag_array.join(", ")     
 end

 def tags 
   @tags ||= self.tag_list
 end

 def save_tags # save new tags
   if @tags # if there are any tags...
     # get rid of old tags
     for tag in self.plugin_tags
       tag.destroy
     end
     
     for tag in self.tags.split(",") # separate tag by comma       
       tag = tag.strip # remove whitespace  
       if !tag.empty?
        tag = PluginTag.new(:name => tag.strip)
        tag.record = self
        tag.is_approved = "1"
        tag.save
       end
    end
  end 
 end 
 
=begin
  # Create Dynamic Attributes from Features
  for feature in PluginFeature.find(:all)
     # Create Setter
     #self.class.class_eval do # remember, class_eval makes instance methods: def method {} end 
      define_method("#{feature.name}=".to_sym) do |value|
        instance_variable_set( "@" + feature.name, val) # instance_variable_set adds def [var] @var end
      end
      
      # Create Getter
      define_method(feature.name.to_sym) do 
        instance_variable_get( "@" + feature.name) # instance_variable_set adds def [var] @var end
      end      
     #end    
    
  end
  
  def method_missing(method_id, *arguments_you_tried_to_pass_in) # handle unknown method
    puts "No Method Found.\nYou tried to run: #{method_id}\nWith the arguments: #{arguments_you_tried_to_pass_in.inspect}" 
  end
=end

  def preview? # does this item have a preview?
   !preview.nil?
  end
  
  def is_record_preview?(some_object) # is this object the preview for this item?
    preview? ? some_object.is_a?(preview_type.constantize) && some_object.id == preview_id : false
  end
  
  def notify
    Emailer.new_item_notification(self).deliver if Setting.global_settings[:new_item_notification]
  end

  # check if user can create more items
  def validate_remaining_items
    if Setting.global_settings[:max_items_per_user].to_i != 0 && !user.is_admin?
      self.errors.add(:count, I18n.t("notice.items_cannot_add_any_more", :items => Item.model_name.human(:count => :other))) if user.items.count >= Setting.global_settings[:max_items_per_user].to_i
    end 
  end
  
  def can?(performer, action, options = {})
    case action.to_sym
    when :view, :read      
      super(performer, action, options) ? true : is_public? && is_approved?    
    else 
      super(performer, action, options)                 
    end
  end    

  def self.can?(performer, action, options = {})
    case action.to_sym
    when :create, :new      
      (Setting.global_settings[:let_users_create_items] || performer.is_admin?) && !performer.anonymous?          
    else 
      super(performer, action, options)                 
    end
  end    
   
end
