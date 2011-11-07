#
# The Image model has been deprecated as of Opal 0.8.0
#

class Image < ActiveRecord::Base
  belongs_to :user

  before_destroy :delete_files

  attr_accessor :original_filename

  def store_dir # rootless storage dir used for paths & urls 
    File.join("images", "uploaded_images", id.to_s, "normal")
  end 

  def thumb_store_dir # rootless storage dir used for paths & urls 
    File.join("images", "uploaded_images", id.to_s, "thumbnails")
  end 

  def path
    Rails.root.join("public", store_dir, filename)
  end

  def thumb_path
    Rails.root.join("public", thumb_store_dir, filename)   
  end
  
  def assign_url
    self.url = File.join(store_dir, filename) if self.url.blank? && !filename.blank?
    self.thumb_url = File.join(thumb_store_dir, filename) if self.thumb_url.blank? && !filename.blank?
  end
  
  def delete_files
    # Remove Image Dir
    image_dir = File.join(File.dirname(path), "..")
    FileUtils.rm_rf(image_dir) if File.exists?(image_dir) # remove the folder if it exists 
  end

  def filename
    @original_filename.blank? ? File.basename(url) : @original_filename
  end
end
