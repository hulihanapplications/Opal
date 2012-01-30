class Page < ActiveRecord::Base
  has_ancestry if Page.table_exists? && column_names.include?("ancestry")

  has_many :pages
  has_many :plugin_comments, :dependent => :destroy, :as => :record
  belongs_to :page
  belongs_to :user  
  
  validates_uniqueness_of :title, :scope => "page_id"
  validates_presence_of :title, :order_number   
  validate :cannot_belong_to_self
  
  before_validation(:on => :create) do 
    self.assign_order_number
  end 

  attr_protected :user_id 

  after_destroy :destroy_everything  
  

  
  #default_scope :order => "order_number asc"
  
  # Scopes
  scope :blog, lambda { where("page_type = ?", "blog")}   
  scope :public, lambda { where("page_type = ?", "public")}   
  scope :system, lambda { where("page_type = ?", "system")}     
  scope :in_order, lambda { order("order_number ASC") }  
  scope :newest_first, lambda { order("created_at DESC") } 
  scope :published, lambda { where(:published => true)}   
  scope :root, lambda { where("page_id = ?", 0)}   
  scope :display_in_menu, where(:display_in_menu => true)   
  scope :for_page, lambda { |page| where("page_id = ?", page.id)}   
  scope :with_name, lambda { |somename| where("name = ?", somename)}  

  def to_s
    title
  end

  def destroy_everything
    for subpage in self.pages # delete all subpages
      if !subpage.deletable # if the subpage is not deletable, move to root
        subpage.update_attribute(:page_id, 0) 
      else 
        subpage.destroy
      end 
    end
  end 


  def validate
    if self.redirect
        validates_format_of :redirect_url, :with => Cregexp.url
    end 
  end

  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with regular integer id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{title.parameterize}" 
  end
  
  def model_name(count = 1) # return human name of instance
    I18n.t("activerecord.models.#{(self.page_type.capitalize + "Page").underscore}", :count => count, :default => Page.model_name) 
  end
  
  def self.public_pages
    where(:page_type => "public")
  end
  
  def self.system_pages
    where(:page_type => "system")
  end  
 
  def self.blog_pages
    where(:page_type => "blog").order("created_at DESC")
  end  
  
  def self.get_system_page(page_title) # retrieve system page by page title
    system_pages.where(:title => page_title).first
  end

  def self.get_public_page(page_title) # retrieve public page by page title
    public_pages.where(:title => page_title).first
  end
   
  def is_system_page?
    self.page_type.downcase == "system"
  end
  
  def is_public_page?
    self.page_type.downcase == "public"
  end

  def is_blog_post?
    self.page_type.downcase == "blog"
  end 
  
  def parent
   if self.page_id == 0
     return nil
   else 
     return Page.find(self.page_id)
   end
  end
 

  
  def self.all(options = {})
    #options[:page_type]
    conditions = Array.new
    conditions << ["page_id = ?", 0] if options[:root_only]
    conditions << ["page_id = ?", options[:page_id] ] if options[:page_id]        
    conditions << ["page_type = ?", options[:page_type].downcase] if options[:page_type]
    conditions << ["display_in_menu = ?", options[:display_in_menu]] if !options[:display_in_menu].nil?
    where(ActiveRecord::Base.combine_conditions(conditions))
  end
  
  def children # get the children of this category
    return Page.find(:all, :conditions => ["page_id = ?", self.id], :order => "title ASC")    
  end 
  
  
  def title # get pretty title
    if self["title"].blank?
      case self.name
      when "items"
        Item.model_name.human(:count => :other)
      when "home"
        I18n.t(:home, :scope => [:single], :default => name.humanize)
      end      
    else
      self["title"]
    end
  end
  
  def can?(performer, action, options = {})
    case action.to_sym
    when :view, :read      
      is_user_owner?(performer) ? true : published 
    when :delete, :destroy
      deletable && super(performer, action, options)  
    else 
      super(performer, action, options)                 
    end
  end   
end
