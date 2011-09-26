Factory.define :plugin_comment do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.comment       "This is a test comment."
end

Factory.define :plugin_comment_anonymous, :parent => :plugin_comment do |o|
  o.anonymous_name "John Doe"
  o.anonymous_email "jdoe@test.com"
end