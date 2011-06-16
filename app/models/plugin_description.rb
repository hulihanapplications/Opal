class PluginDescription < ActiveRecord::Base
  acts_as_opal_plugin

  belongs_to :plugin
  belongs_to :item
  belongs_to :user
end
