class Page < ActiveRecord::Base
  has_many :pages
  has_many :page_comments
  belongs_to :page
  belongs_to :user
  
  validates_uniqueness_of :title, :scope => "page_id"
  validates_presence_of :title 

    
    
  attr_protected :user_id 

  after_destroy :destroy_everything  
  after_create  :assign_order_number

  def destroy_everything
    for subpage in self.pages # delete all subpages
      if !subpage.deletable # if the subpage is not deletable, move to root
        subpage.update_attribute(:page_id, 0) 
      else 
        subpage.destroy
      end 
    end
    
    for item in self.page_comments # delete all comments
      item.destroy
    end
  end 


  def validate
    if self.redirect
        validates_format_of :redirect_url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
    end 
  end

  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with regular integer id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{title.parameterize}" 
  end
  
  def model_name # return human name of instance
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
 
  def assign_order_number
    self.update_attribute(:order_number, self.class.next_order_number) # assign next order number
  end

  def self.next_order_number # >> Returns the next order_number. Example: Plugin.next_order_number => 8 
    last_object = Page.find(:last, :order => "order_number ASC")
    (last_object.nil? || last_object.order_number.nil?) ? order_number = 0 : order_number = last_object.order_number + 1  
    return order_number
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
  
  def model_name # get model name
    I18n.t("activerecord.models.#{(self.page_type.capitalize + "Page").underscore}", :default => Page.model_name)
  end
end
