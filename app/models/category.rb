class Category < ActiveRecord::Base
 include ActionView::Helpers::TextHelper # include text helper for truncate and other options
 has_ancestry if Category.table_exists? && column_names.include?("ancestry")
 
 has_many :items, :dependent => :destroy
 has_many :categories, :dependent => :destroy
 belongs_to :category
 
 validates_presence_of :name, :message => "This field is required!"

 def to_param # make custom parameter generator for seo urls
    "#{id}-#{name.parameterize}"
 end
  
 def self.get_parent_categories # Category.get_parent_categories
   return find(:all, :conditions =>["category_id = 0"], :order => "name ASC")         
 end
 
 def parent_category
   if self.category_id == 0
     return nil
   else 
     return Category.find(self.category_id)
   end
 end
 
  def get_item_count(options = {:include_children => false}) # gets a category's item count     
    total_item_count = 0 
    # Add Item Count for category
    items_in_category = Item.count(:all, :select => "id", :conditions => ["category_id = ? and is_approved = '1' and is_public = '1'", self.id])
    total_item_count += items_in_category.to_i
    if options[:include_children] # if enabled, do recursive item count
      # call recursive function for each child_category
      child_categories = Category.find(:all, :select => "id", :conditions => ["category_id = ?", self.id])    
      for child_category in child_categories
        total_item_count += child_category.get_item_count(:include_children => options[:include_children])
      end 
    end 
    return total_item_count
  end
 
  def get_items   
    # Deprecated as of 0.1.8 
  end
  
  def get_all_ids(options = {:include_children => false}) # recursive category id lookup, returns ids(in csv) to use in Mysql WHERE IN clause
    string = "#{self.id}" # add category id
    if options[:include_children] # if enabled get all children categories' ids
      child_categories = Category.find(:all, :select => "id,category_id", :conditions => ["category_id = ?", self.id])    
      for child_category in child_categories
        string += ",#{child_category.get_all_ids(:include_children => options[:include_children])}"
      end
    end 
    return string
  end 
 
  def child_categories # get the children of this category
    return Category.find(:all, :conditions => ["category_id = ?", self.id], :order => "name ASC")    
  end
  
  def descendant_of?(some_category)    
    self.id == some_category.id ? true : self.category ? self.category.descendant_of?(some_category) : false  
  end  
  

end
