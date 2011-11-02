class PluginImage < ActiveRecord::Base
  acts_as_opal_plugin

  mount_uploader :image, ::ImageUploader

  belongs_to :plugin
  belongs_to :user
  
  validates :image, :presence => true, :if => Proc.new{|r| r.remote_image_url.blank?} 
  #validates :remote_image_url, :presence => true, :if => Proc.new{|r| r.image.blank?} 
   
  attr_accessible :description, :remove_image#, :effects, :image, :remote_image_url
  attr_accessor :effects
  
  def to_s
  	filename
  end 

  def filename
    File.basename(image.path)
  end
end
