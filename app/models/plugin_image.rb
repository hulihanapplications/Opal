class PluginImage < ActiveRecord::Base
  acts_as_opal_plugin

  belongs_to :plugin
  belongs_to :item
  belongs_to :user
  
  before_destroy :delete_files
  
  validates_uniqueness_of :url, :scope => :item_id, :message => "There is already an image with this filename!"
  
  def delete_files
    image_path = "#{Rails.root.to_s}/public" + "#{self.url}"
    thumb_path = "#{Rails.root.to_s}/public" + "#{self.thumb_url}"

    if File.exists?(image_path) # does the file exist?
     FileUtils.rm(image_path) # delete the file
    else # file doesn't exist
     self.errors.add('error', "System couldn't delete the normal file: #{image_path}! Continuing...")
    end

    if File.exists?(thumb_path) # does the file exist?
     FileUtils.rm(thumb_path) # delete the file
    else # file doesn't exist
     self.errors.add('error',  "System couldn't find the thumbnail file: #{thumb_path}! Continuing...")
    end
 end


  def filename # get filename from url 
    return File.basename(self.url)
  end
  
 def to_html 
   return "<img src=\"#{self.url}\">" 
 end
end
