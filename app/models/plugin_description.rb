class PluginDescription < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  acts_as_opal_plugin

  belongs_to :plugin
  belongs_to :item
  belongs_to :user
  
  def to_s
  	truncate(strip_tags(content), :length => 50)
  end  
end
