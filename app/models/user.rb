class User < ActiveRecord::Base
  require 'digest/sha2'

  make_voter
  mount_uploader :avatar, ::AvatarUploader

  has_many :authentications, :dependent => :destroy
  has_one :user_info, :dependent => :destroy
  has_many :user_messages, :dependent => :destroy
  has_many :pages, :dependent => :nullify
  has_many :page_comments, :dependent => :destroy
  has_many :user_verifications, :dependent => :destroy
  has_many :logs
  has_many :items, :dependent => :destroy  
  has_many :plugin_comments, :dependent => :destroy
  has_many :plugin_descriptions, :dependent => :destroy
  has_many :plugin_discussions, :dependent => :destroy
  has_many :plugin_discussion_posts, :dependent => :destroy  
  has_many :plugin_feature_values, :dependent => :destroy
  has_many :plugin_files, :dependent => :destroy
  has_many :plugin_images, :dependent => :destroy
  has_many :plugin_links, :dependent => :destroy
  has_many :plugin_reviews, :dependent => :destroy
  has_many :plugin_review_votes, :dependent => :destroy
  has_many :plugin_tags, :dependent => :destroy
  has_many :plugin_videos, :dependent => :destroy  
  belongs_to :group
  
  validates_uniqueness_of :username #this will comb through the database and make sure email is unique
  validates_uniqueness_of :email #this will comb through the database and make sure email is unique
  validates_presence_of :username, :email
  validates_confirmation_of :password # this will confirm the password, but you have to have an html input called password_confirmation
  validates_length_of :username, :maximum => 255
  #validates_numericality_of :zip
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  before_save :strip_html
  after_create :create_everything
  after_create :set_verification  
  after_create :notify
  after_destroy :destroy_everything
  after_destroy :delete_avatar
  attr_accessor :password_confirmation, :password # virtual attributes
  attr_protected :is_admin, :is_verified, :is_disabled, :title # protect from bulk assignment  
  
  scope :latest_logins, :limit => 5, :order => "last_login_at DESC"
  scope :logged_in, where(["last_request_at > ?", 5.minutes.ago]).order("last_request_at DESC")
  
  # Authentication! 
    # Enable Authlogic
    acts_as_authentic do |c| 
      c.validate_email_field     = false
      c.validate_login_field     = false
      c.validate_password_field  = false
    end
    
    def password?(password) # check if this password is the user's password
     self.password_hash == hash_password(password)
   end
   
    def self.authenticate(login, password)
      u = self.find(:first, :conditions => ["username = ? and password_hash = ?", login, hash_password(password) ] )# check username column with the hashed pass arg
      return u
    end     
    
    def password=(pass) # set password, encrypt password on assignment
      @password = pass 
      self.salt = User.generate_salt # generate new salt
      self.password_hash = hash_password(pass)
    end
    
    def hash_password(pass) # hash that password
      Digest::SHA256.hexdigest(pass + (salt.blank? ? "" : salt))
    end
  
    def self.generate_salt
      salt = String.new
      64.times { salt << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
      return salt
    end
   
    def assign_salt # assign a salt if it don't exist.
      self.salt = User.generate_salt
    end 
    
  def self.search(search, page)
    paginate :per_page => 5, :page => page,
             :conditions => ['username like ?', "%#{search}%"],
             :order => 'username'
  end

  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{username.parameterize}" 
  end
  
  def to_s
    self.username
  end
  
  def is_admin? 
   if self.is_admin == "1" || self.group.is_admin_group?
    return true
   else 
    return false
   end
  end
  
  def destroy_everything
    avatars_path = "#{Rails.root.to_s}/public/images/avatars"
    avatar_path = "#{avatars_path}/#{self.id}.png"
    if File.exists?(avatar_path) # check if avatar exists
      FileUtils.rm(avatar_path) # delete!
    end
    
    for vote in votings # destroy make_voteable votes
      vote.destroy
    end    
  end
  
  def create_everything
    # Create User Info
    user_info = UserInfo.new
    user_info.user_id = self.id
    user_info.save    
  end

 def strip_html # Automatically strips any tags from any string to text typed column
    for column in User.content_columns
      if column.type == :string || column.type == :text # if the column is a sql string or text
        self[column.name] = self[column.name].gsub(/<\/?[^>]*>/, "")  if !self[column.name].nil? # strip html from string
      end
    end
 end

  def use_gravatar?
    self.user_info ? self.user_info.use_gravatar == "1" : false
  end

  def is_enabled?
    if self.is_disabled == "1" 
      return false
    else 
      return true
    end    
  end

  def is_verified?
    if self.is_verified == "1" || self.is_admin? # you don't have to be verified if you're an admin.
      return true
    else 
      return false
    end      
  end
  
  def self.admins # get all admins
    return User.find(:all, :conditions => ["is_verified = '1' and is_disabled = '0' and is_admin = '1'"])
  end
  
  def anonymous? # is the user an anonymous user?
    (self.id == 0 || self.id.nil?)   
  end
  
  def self.anonymous # generate anonymous user
    u = User.new(:username => "Guest", :first_name => "No", :last_name => "Name")
    u.id = 0       
    u.group_id = 1 # set for public group
    u.locale = Setting.global_settings[:locale] # set system default locale
    return u     
  end
  
  def items_remaining
    max_items = Setting.get_setting("max_items_per_user")
    if max_items.to_i != 0 
     items_remaining = max_items.to_i - self.items.count
     return items_remaining
    else # user can create unlimited items 
     return nil
    end      
  end
  
  def can_create_item?
    is_admin? || ((items_remaining.nil? || items_remaining > 0) && !anonymous?) 
  end
  
  def apply_omniauth(omniauth) # fill attributes based on received omniauth data
    if omniauth['user_info']
      self.email = omniauth['user_info']['email'] if self.email.blank?
      self.first_name = omniauth["user_info"]['first_name'] if omniauth["user_info"]['first_name'] && self.first_name.blank?
      self.last_name = omniauth["user_info"]['last_name'] if omniauth["user_info"]['last_name'] && self.last_name.blank?
    end 

    # Update user info fetching from social network
    case omniauth['provider']
    when 'facebook'  
      # fetch extra user info from facebook
    when 'twitter'
      # fetch extra user info from twitter
    end
  end

  def generate_username # generate a random username
    s = Array.new
    s << self.first_name.downcase unless self.first_name.blank?
    s << String.random(:mode => :num) # if !self.first_name.blank? && User.find_by_username(self.first_name.downcase)
    self.username = s.join("-")    
  end
  
  def set_verification
    if Setting.get_setting_bool("email_verification_required") 
      update_attribute(:is_verified, "0") 
      verification = UserVerification.create(:user_id => id, :code => UserVerification.generate_code)
      verification.send_email
    else 
      update_attribute(:is_verified, "1") 
    end 
  end
    
  def notify
    Emailer.new_user_notification(self).deliver if Setting.get_setting_bool("new_user_notification")                 
  end

  def delete_avatar
    if avatar && avatar.path
      FileUtils.rmdir(File.dirname(avatar.path)) if File.exists?(File.dirname(avatar.path)) # remove CarrierWave store dir, must be empty to work
    end 
  end
    
end
