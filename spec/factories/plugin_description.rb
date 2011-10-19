Factory.define :plugin_description do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.title         "Test Title"
  o.content       "Test Content"
end