FactoryGirl.define do
  factory :page do |o|
    o.association   :user, :factory => :user
    o.published     true
    o.title         "Test Page"
    o.description   "This is a test description"
    o.content       '<div style="text-align: center;">This is some test content!</div>' 
  end
end
  
FactoryGirl.define do
  factory :blog_post, :parent => :page do |o|
    o.title         "Test Blog Post"
  end
end
  
FactoryGirl.define do
  factory :page_with_redirect, :parent => :page do |o|
    o.redirect true
    o.redirect_url "http://www.google.com"
  end
end
  
FactoryGirl.define do
  factory :group_access_only_page, :parent => :page do |o|
    o.group_access_only   true
    o.group_ids           []
  end
end