Factory.define :plugin_description do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.title
  o.content
end