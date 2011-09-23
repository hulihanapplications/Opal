Factory.define :plugin_tag do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.name          "Tag"
end
