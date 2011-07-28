class PluginVideo < ActiveRecord::Base
  acts_as_opal_plugin

  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  belongs_to :item
  belongs_to :user

  #validates_presence_of :title 
  
  before_validation :sanitize_code 
  
  attr_accessible :code, :title, :description
  
  default_scope :order => "title ASC"

  def to_s
  	title.blank? ? truncate(code, :length => 50) : title 
  end

  def sanitize_code
    self.code = sanitize(self.code)
  end
end
