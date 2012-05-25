FactoryGirl.define do
  factory :category do |o|
    o.sequence(:name) { |n| "Category #{n}" }  
  end
end