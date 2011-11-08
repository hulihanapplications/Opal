Factory.define :page do |o|
  o.association   :user, :factory => :user
  o.published     true
  o.title         "Test Page"
  o.description   "This is a test description"
  o.content       '<div style="text-align: center;">This is some test content!</div>' 
end

Factory.define :page_with_redirect, :parent => :page do |o|
  o.redirect true
  o.redirect_url "/"
end
