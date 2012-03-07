I18n.locale = ENV['LOCALE'].nil? ? "en" : ENV['LOCALE']  # Define locale 

admin = User.first

#Create Verified user
user = User.new(:first_name => I18n.t('sample_data.users.test.first_name'), :last_name => I18n.t('sample_data.users.test.last_name'), :username => I18n.t('sample_data.users.test.username'), :password => I18n.t('sample_data.users.test.password'), :password_confirmation => I18n.t('sample_data.users.test.password'), :email => I18n.t('sample_data.users.test.email'))
user.is_verified = "1" # verify them(attr_protected otherwise)
user.save

#Create Unverified user
unverified_user = User.create(:first_name => I18n.t('sample_data.users.unverified.first_name'), :last_name => I18n.t('sample_data.users.unverified.last_name'), :username => I18n.t('sample_data.users.unverified.username'), :password => I18n.t('sample_data.users.unverified.password'), :password_confirmation => I18n.t('sample_data.users.unverified.password'), :email => I18n.t('sample_data.users.unverified.email'))

#Create User Messages
msg = UserMessage.new(:message => I18n.t('sample_data.messages.unread.text'))
msg.from_user_id = admin.id
msg.user_id = user.id
msg.to_user_id = user.id
msg.save
msg = UserMessage.new(:message => I18n.t('sample_data.messages.read.text'), :is_read => "1")
msg.from_user_id = admin.id
msg.user_id = user.id
msg.to_user_id = user.id
msg.save    
msg = UserMessage.new(:message => I18n.t('sample_data.messages.reply.text'), :reply_to_message_id => 1)
msg.from_user_id = user.id
msg.user_id = admin.id
msg.to_user_id = admin.id  
msg.save     

# Create Test Item
item1 = Item.new(:name => I18n.t('sample_data.items.sample.name'), :description => I18n.t('sample_data.items.sample.description'))
item1.user_id = admin.id
item1.is_public = "1"
item1.featured = true
item1.is_approved = "1"
item1.save

item2 = Item.new(:name => I18n.t('sample_data.items.long_name.name'), :description => I18n.t('sample_data.items.long_name.description'))
item2.user_id = user.id
item2.is_public = "1"
item2.is_approved = "1"
item2.save

item3 = Item.new(:name => I18n.t('sample_data.items.unapproved.name'), :description => I18n.t('sample_data.items.unapproved.description'))
item3.user_id = user.id
item3.save  

# Create Plugins 
sample_image_path = Rails.root.join("spec", "fixtures", "images", "example.png")
if File.exists?(sample_image_path)
sample_image = File.open(sample_image_path) 
plugin = PluginImage.new(:image => sample_image, :description => I18n.t('sample_data.plugins.images.sample.description'))
plugin.record = item1
plugin.user_id = admin.id 
plugin.is_approved = "1"    
plugin.save

plugin = PluginFile.new(:file => sample_image)
plugin.record = item1
plugin.user_id = admin.id 
plugin.is_approved = "1"    
plugin.save    
end  

plugin = PluginComment.new(:comment => I18n.t('sample_data.plugins.comments.sample.text'))
plugin.record = item1
plugin.is_approved = "1"    
plugin.user_id = admin.id 
plugin.save    

plugin = PluginDescription.new(:title => I18n.t('sample_data.plugins.descriptions.sample.title'), :content => I18n.t('sample_data.plugins.descriptions.sample.content'))
plugin.record = item1
plugin.is_approved = "1"    
plugin.user_id = admin.id 
plugin.save

# Create  Features
plugin = PluginFeature.new(:name => I18n.t('sample_data.plugins.features.price.name'), :order_number => 0)
plugin.save    
  plugin_feature_value = PluginFeatureValue.new(:value => I18n.t('sample_data.plugins.features.price.value'))
  plugin_feature_value.plugin_feature_id = plugin.id
  plugin_feature_value.is_approved = "1"        
  plugin_feature_value.record = item1
  plugin_feature_value.user_id = admin.id 
  plugin_feature_value.save    
    
plugin = PluginFeature.new(:name => I18n.t('sample_data.plugins.features.size.name'), :order_number => 1, :feature_type => "option")    
plugin.save
PluginFeatureValueOption.create(:value => I18n.t('sample_data.plugins.features.size.option_small'), :plugin_feature_id => plugin.id)
PluginFeatureValueOption.create(:value => I18n.t('sample_data.plugins.features.size.option_medium'), :plugin_feature_id => plugin.id)
PluginFeatureValueOption.create(:value => I18n.t('sample_data.plugins.features.size.option_large'), :plugin_feature_id => plugin.id)  
  plugin_feature_value = PluginFeatureValue.new(:value => I18n.t('sample_data.plugins.features.size.option_large'))
  plugin_feature_value.plugin_feature_id = plugin.id
  plugin_feature_value.is_approved = "1"        
  plugin_feature_value.record = item1
  plugin_feature_value.user_id = admin.id 
  plugin_feature_value.save        

plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.date.name'), :order_number => 1, :feature_type => "date")    
plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.rank.name'), :order_number => 1, :feature_type => "slider", :min => 1, :max => 10)    
plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.score.name'), :order_number => 1, :feature_type => "stars", :max => 5)    
plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.is_this_awesome.name'), :order_number => 1, :feature_type => "yesno", :max => 5)    

plugin = PluginReview.new(:review_score => 5, :review => I18n.t('sample_data.plugins.reviews.sample.text'))
plugin.record = item1
plugin.is_approved = "1"    
plugin.user_id = admin.id
plugin.save    

plugin = PluginLink.new(:title => I18n.t('sample_data.plugins.links.sample.title'), :url => "http://www.hulihanapplications.com")
plugin.record = item1
plugin.is_approved = "1"
plugin.user_id = admin.id 
plugin.save    

plugin = PluginTag.new(:name => I18n.t('sample_data.plugins.tags.sample.name'))
plugin.record = item1
plugin.is_approved = "1"    
plugin.user_id = admin.id 
plugin.save   

tag = PluginTag.create(:name => I18n.t('sample_data.plugins.tags.cool.name'), :record => item1)
tag.user = user
tag.is_approved = "1"
tag.save
tag = PluginTag.create(:name => I18n.t('sample_data.plugins.tags.cool.name'), :record => item2)
tag.is_approved = "1"
tag.user = user  
tag.save

# Sample Discussion
discussion = PluginDiscussion.new(:record => item1, :user_id => admin.id, :title => I18n.t('sample_data.plugins.discussions.sample.title'), :description => I18n.t('sample_data.plugins.discussions.sample.description'))
discussion.is_approved = "1"
discussion.save

discussion_post = PluginDiscussionPost.create(:user_id => user.id, :plugin_discussion_id => discussion.id, :post => I18n.t('sample_data.plugins.discussions.sample.post'))

plugin = PluginVideo.new(:title => I18n.t('sample_data.plugins.videos.sample.title'), :description => I18n.t('sample_data.plugins.videos.sample.description'), :code => I18n.t('sample_data.plugins.videos.sample.code'))
plugin.record = item1
plugin.is_approved = "1"    
plugin.user_id = admin.id 
plugin.save    

sample_video_path = Rails.root.join("spec", "fixtures", "videos", "example.flv")
sample_video = File.new(sample_video_path) 
plugin = PluginVideo.new(:video => sample_video, :title => I18n.t('sample_data.plugins.videos.uploaded.title'), :description => I18n.t('sample_data.plugins.videos.uploaded.description'))
plugin.record = item2
item2.preview = plugin
item2.save
plugin.is_approved = "1"    
plugin.user_id = admin.id 
plugin.save    

# Create Public Page
pages = Hash.new
pages[:about] = Page.create(:title => I18n.t('sample_data.pages.about.title'), :description => I18n.t('sample_data.pages.about.description'), :page_type => "public", :content => I18n.t('sample_data.pages.about.content'))
pages[:more_about] = Page.create(:title => I18n.t('sample_data.pages.more_about.title'), :page_id => pages[:about].id, :description => I18n.t('sample_data.pages.more_about.description'), :page_type => "public", :content => I18n.t('sample_data.pages.more_about.content'))

# Create Blog Post
blog_page = Page.new(:title => I18n.t('sample_data.pages.blog_post.title'), :content => I18n.t('sample_data.pages.blog_post.content'), :page_type => "blog")
blog_page.save

# Extra Categories
Category.create(:name => I18n.t('sample_data.categories.uncategorized_child.name'), :category_id => 1, :description => I18n.t('sample_data.categories.uncategorized_child.description'))
Category.create(:name => I18n.t('sample_data.categories.uncategorized_grand_child.name'), :category_id => 2, :description => I18n.t('sample_data.categories.uncategorized_grand_child.description'))
