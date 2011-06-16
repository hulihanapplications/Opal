class PluginLink < ActiveRecord::Base
  acts_as_opal_plugin

  belongs_to :plugin
  belongs_to :item
  belongs_to :user

  validates_presence_of :title, :url
end
