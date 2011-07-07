Factory.define :plugin_image do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.url           "/path/to/image"
end
