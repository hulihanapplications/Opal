class PluginLink < ActiveRecord::Base
  acts_as_opal_plugin

  belongs_to :plugin
  belongs_to :user

  validates_presence_of :title, :url
  
  attr_accessible :title, :url

  def to_s
  	get_title
  end

  def get_title # get the title of the file, either bare filename or user-inputted 
    title.blank? ? url : title
  end  
end
