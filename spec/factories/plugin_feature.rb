FactoryGirl.define do
  factory :plugin_feature do |o|
    o.association   :user, :factory => :user
    o.name          "Test Feature"
    o.feature_type  "Text"
  end
end