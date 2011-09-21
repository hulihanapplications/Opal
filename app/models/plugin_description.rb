class PluginDescription < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  acts_as_opal_plugin

  belongs_to :plugin
  belongs_to :user
  
  attr_accessible :title, :content

  before_validation lambda{|o| o.sanitize_content(:content)}
  
  def to_s
  	truncate(strip_tags(content), :length => 50)
  end  
end
