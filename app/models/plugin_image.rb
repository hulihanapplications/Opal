class PluginImage < ActiveRecord::Base
  acts_as_opal_plugin

  mount_uploader :image, ::ImageUploader

  belongs_to :plugin
  belongs_to :user
  
  #validates_presence_of :image
  
  attr_accessible :description, :image, :remove_image, :remote_image_url
  attr_accessor :effects
  
  def to_s
  	filename
  end 

  def filename
    File.basename(image.path)
  end
end
