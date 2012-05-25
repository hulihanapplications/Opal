FactoryGirl.define do
  factory :group do |o|
    o.sequence(:name) { |n| "Group #{n}" }  
  end
end