class Image < ActiveRecord::Base
  belongs_to :user

  before_destroy :delete_files

  
  #validates_uniqueness_of :url, :scope => :item_id, :message => "There is already an image with this filename!"
  
  def delete_files
    image_dir = File.join(Rails.root.to_s, "public", "images", "uploaded_images", self.id.to_s)

    # Remove Image Folder
    FileUtils.rm_rf(image_dir) if File.exist?(image_dir) # remove the folder if it exists 
  end


end
