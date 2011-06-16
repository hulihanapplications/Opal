class PluginVideo < ActiveRecord::Base
  acts_as_opal_plugin

  belongs_to :item
  belongs_to :user

  validates_presence_of :title 
  
  before_validation :sanitize_code 
  
  default_scope :order => "title ASC"

  def sanitize_code
    include ActionView::Helpers::SanitizeHelper
    self.code = sanitize(self.code)
  end
end
