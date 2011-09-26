Factory.define :plugin_feature_value do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.association   :plugin_feature, :factory => :plugin_feature
  o.value         "Test Value"
  o.is_approved   "1"
end
