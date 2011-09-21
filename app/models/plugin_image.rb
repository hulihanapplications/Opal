class PluginImage < ActiveRecord::Base
  acts_as_opal_plugin

  mount_uploader :image, ::ImageUploader

  belongs_to :plugin
  belongs_to :user
  
  validates_presence_of :image
  after_destroy :delete_files
  
  attr_accessible :description, :image, :remove_image, :remote_image_url
  attr_accessor :effects
  
  def to_s
  	filename
  end 
  
  def delete_files
    FileUtils.rmdir(File.dirname(image.path)) if File.exists?(File.dirname(image.path)) # remove CarrierWave store dir, must be empty to work
  end

  def filename
    File.basename(image.path)
  end
end
