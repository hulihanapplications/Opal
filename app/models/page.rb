class Page < ActiveRecord::Base
  has_many :pages
  has_many :page_comments
  belongs_to :page
  after_destroy :destroy_everything
  belongs_to :user
  
  validates_uniqueness_of :title, :scope => "page_id"
  validates_presence_of :title 
  
  attr_protected :user_id 

  def destroy_everything
    for item in self.pages # delete all subpages
      item.destroy
    end
    
    for item in self.page_comments # delete all comments
      item.destroy
    end
  end 


  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with regular integer id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{title.parameterize}" 
  end
  
  def human_name # return human name of instance
    I18n.t("activerecord.models.#{(self.page_type.capitalize + "Page").underscore}") 
  end
  
  def self.public_pages
    return Page.find(:all, :conditions => ["page_type = ?", "public"])
  end
  
  def self.system_pages
    return Page.find(:all, :conditions => ["page_type = ?", "system"])
  end  
 
  def self.blog_pages
    return Page.find(:all, :conditions => ["page_type = ?", "blog"], :order => "created_at DESC")
  end  
  
  def self.get_system_page(page_title) # retrieve system page by page title
    return Page.find(:first, :conditions => ["page_type = ? and title = ?", "system", page_title])
  end

  def self.get_public_page(page_title) # retrieve public page by page title
    return Page.find(:first, :conditions => ["page_type = ? and title = ?", "public", page_title])
  end
   

  
  def is_system_page?
    if self.page_type == "system"
      return true
    else 
      return false
    end
  end
  
  def is_public_page?
    if self.page_type == "public"
      return true
    else 
      return false
    end
  end

  def is_blog_post?
    if self.page_type == "blog_post"
      return true
    else 
      return false
    end
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
    conditions << ["page_type = ?", options[:page_type].downcase] if options[:page_type]
    
    where(ActiveRecord::Base.combine_conditions(conditions))
  end
  
  def children # get the children of this category
    return Page.find(:all, :conditions => ["page_id = ?", self.id], :order => "title ASC")    
  end 
end
