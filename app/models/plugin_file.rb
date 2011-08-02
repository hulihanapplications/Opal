class PluginFile < ActiveRecord::Base
  acts_as_opal_plugin
  
  belongs_to :plugin
  belongs_to :item
  belongs_to :user
  
  before_destroy :delete_file
  
  validates_uniqueness_of :filename, :scope => :item_id, :message => "This item already has a file with this name!"

  def to_s
    get_title	
  end
  
  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with regular integer id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{self.get_title.gsub(/[^a-z0-9]+/i, '-')}" 
  end  
  
  def get_title # get the title of the file, either bare filename or user-inputted 
    if self.title? # file has a title?
      file_title = self.title 
    else # no title, use filename
      file_title = File.basename(self.filename)
    end    
    return file_title
  end
  
  def delete_file
    file = Rails.root.to_s + "/files/item_files/#{self.item_id}/#{self.filename}"

    if File.exists?(file) # does the file exist?
     FileUtils.rm(file) # delete the file
    else # file doesn't exist
     self.errors.add('error', "System couldn't delete the file: #{file}! Continuing...")
    end
  end
  
  def path # the path to the file
    return Rails.root.to_s + "/files/item_files/#{self.item_id}/#{self.filename}"
  end 
end
