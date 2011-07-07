Factory.define :plugin_discussion do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.title         "Test Discussion"
  o.description
  o.is_sticky
  o.is_closed
end