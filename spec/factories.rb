Factory.define :admin, :class => User do |o|
  o.first_name 'Bob'
  o.last_name  'Jones'
  o.username   'admin'
  #o.sequence(:username) { |n| "admin#{n}" }  
  o.password   'admin'
  o.email      'admin@test.com'
  #o.sequence(:email) { |n| "admin#{n}@test.com" }  
  o.is_admin   '1'  
  o.locale     'en'
end


Factory.define :user do |o|
  o.first_name 'John'
  o.last_name  'Doe'
  o.username   'test'
  #o.sequence(:username) { |n| "test#{n}" }  
  o.password   'test'
  o.email      'test@test.com'
  #o.sequence(:email) { |n| "test#{n}@test.com" }  
  o.is_admin   '0'  
  o.locale     'en'
end

Factory.define :new_user, :parent => :user  do |o|
  o.sequence(:username) { |n| "test#{n}" }  
  o.sequence(:email) { |n| "test#{n}@test.com" }  
end

Factory.define :category do |o|
  o.sequence(:name) { |n| "Category #{n}" }  
end

Factory.define :group do |o|
  o.sequence(:name) { |n| "Group #{n}" }  
end


Factory.define :item do |o|
  o.sequence(:name) { |n| "Item #{n}" }
  o.description   "This is a test desciption!"
  o.association   :category, :factory => :category
  o.association   :user, :factory => :new_user
  #o.user_id       Factory.build(:user).id
  o.is_public     "1"
  o.is_approved   "1"
  o.featured      true
  o.locked        false
  o.views         20
  o.recent_views  10
end