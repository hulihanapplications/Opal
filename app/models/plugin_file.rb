class PluginFile < ActiveRecord::Base
  acts_as_opal_plugin

  mount_uploader :file, ::FileUploader

  belongs_to :plugin
  belongs_to :user
  
  attr_accessible :title, :file, :remove_file, :remote_file_url
  
  def to_s
    get_title 
  end
  
  def to_param # make custom parameter generator for seo urls, to use: pass actual object(not id) into id ie: :id => object
    # this is also backwards compatible with regular integer id lookups, since .to_i gets only contiguous numbers, ie: "4-some-string-here".to_i # => 4    
    "#{id}-#{self.get_title.gsub(/[^a-z0-9]+/i, '-')}" 
  end  
  
  def get_title # get the title of the file, either bare filename or user-inputted 
    !self.title.blank? ? self.title : filename.blank? ? self["file"] : filename
  end
  
  # get filename. If "filename" column exists, return that. Otherwise get it from carrierwave attachment
  def filename
    self.class.column_names.include?("filename") ? (self["filename"] ? self["filename"] : self["file"]) : (file.path.blank? ? "" : File.basename(file.path))  
  end  
end
