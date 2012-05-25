FactoryGirl.define do
  factory :item do |o|
    o.sequence(:name) { |n| "Item #{n}" }
    o.description   "This is a test desciption!"
    o.association   :category, :factory => :category
    o.association   :user, :factory => :user
    #o.user_id       Factory.build(:user).id
    o.is_public     "1"
    o.is_approved   "1"
    o.featured      true
    o.locked        false
    o.views         20
    o.recent_views  10
  end
end
  
FactoryGirl.define do
  factory :item_with_plugins, :parent => :item do |o|
    after :build do |o|
      o.plugin_comments = [FactoryGirl.create(:plugin_comment, :record => o)]
      o.plugin_descriptions = [FactoryGirl.create(:plugin_description, :record => o)]
      o.plugin_discussions = [FactoryGirl.create(:plugin_discussion, :record => o)]
      o.plugin_feature_values = [FactoryGirl.create(:plugin_feature_value, :record => o)]
      o.plugin_files = [FactoryGirl.create(:plugin_file, :record => o)]
      o.plugin_images = [FactoryGirl.create(:plugin_image, :record => o)]
      o.plugin_links = [FactoryGirl.create(:plugin_link, :record => o)]
      o.plugin_reviews = [FactoryGirl.create(:plugin_review, :record => o)]
      o.plugin_tags = [FactoryGirl.create(:plugin_tag, :record => o)]
      o.plugin_videos = [FactoryGirl.create(:plugin_video, :record => o)]
    end
  end
end