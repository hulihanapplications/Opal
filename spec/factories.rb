Factory.define :user do |u|
  u.first_name 'John'
  u.last_name  'Doe'
  u.username   'test'
  u.password   'test'
  u.email      'test@test.com'
  u.is_admin   '0'  
end

Factory.define :admin, :class => User do |u|
  u.first_name 'Bob'
  u.last_name  'Jones'
  u.username   'admin'
  u.password   'admin'
  u.email      'admin@test.com'
  u.is_admin   '1'  
end