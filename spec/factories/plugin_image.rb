Factory.define :plugin_image do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.url           "/path/to/image"
end

Factory.define :plugin_image_remote, :parent => :plugin_image do |o|
  o.remote_file "http://localhost/"
end
