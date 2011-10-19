Factory.define :plugin_discussion do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.title         "Test Discussion"
  o.description   "Test Description"
  o.is_sticky     "0"
  o.is_closed     "0"
end