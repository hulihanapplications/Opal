Factory.define :plugin_discussion_post do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.association   :plugin_discussion, :factory => :plugin_discussion
  o.post          "This is a test post."
end