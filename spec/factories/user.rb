Factory.define :user do |o|
  o.first_name 'John'
  o.last_name  'Doe'
  o.sequence(:username) { |n| "test#{n}" }  
  o.password   'test'
  o.sequence(:email) { |n| "test#{n}@test.com" }  
  o.is_admin   '0'  
  o.locale     'en'
end

Factory.define :admin, :parent => :user do |o|
  o.is_admin   '1'  
end
