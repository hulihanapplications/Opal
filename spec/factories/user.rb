FactoryGirl.define do
  factory :user do |o|
    o.first_name 'John'
    o.last_name  'Doe'
    o.sequence(:username) { |n| "test#{n}" }  
    #o.group Group.user
    o.password   'test'
    o.sequence(:email) { |n| "test#{n}@test.com" }  
    o.is_admin   '0'  
    o.locale     'en'
  end
end
  
FactoryGirl.define do
  factory :admin, :parent => :user do |o|
    o.is_admin   '1'  
  end
end
  
FactoryGirl.define do
  factory :user_with_avatar, :parent => :user do |o|
    file = File.new(Rails.root + 'spec/fixtures/images/example.png')
    o.avatar ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file.path))
  end
end
