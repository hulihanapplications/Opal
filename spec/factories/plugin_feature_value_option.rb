Factory.define :plugin_feature_value_option do |o|
  o.association :plugin_feature, :factory => :plugin_feature
  o.association :user, :factory => :user
  o.value
  o.description
end