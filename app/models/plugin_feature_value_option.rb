class PluginFeatureValueOption < ActiveRecord::Base
  # FeatureValueOptions let users select from pre-defined values for a particular Feature. 
  # Example: If there was a feature called "Size", you could create a FeatureValueOption 
  #          called "Medium", that a user could select instead of typing "Medium"
  belongs_to :plugin_feature
  belongs_to :user

  default_scope :order => "created_at ASC"

  validates_presence_of :value
end
