# This file creates required & sample data for new installations. 


def prompt(msg, default_value = "") # prompt user and get value
  if default_value != ""
    print msg + " (#{I18n.t('single.default')}: #{default_value}) "
  else
    print msg + " "
  end 
  entered_value = STDIN.gets  
  entered_value = entered_value.chomp # strip input of newline/carriage return
  entered_value = default_value if entered_value == "" # if they didn't 
  return entered_value
end  

ENV["PROMPTS"] ||= "TRUE" # turn prompts on by default    

I18n.locale = ENV['LOCALE'].nil? ? "en" : ENV['LOCALE']  # Define locale 

# Required Data
print I18n.t('label.installing') 

# Create Global Settings
Setting.create(:name => "site_title",  :value => I18n.t('seeds.setting.site_title'), :setting_type => "Public",  :item_type => "string")
Setting.create(:name => "site_description",  :value => I18n.t('seeds.setting.site_description'), :setting_type => "Public",  :item_type => "string")
Setting.create(:name => "theme",  :value => "fracture", :setting_type => "Hidden",  :item_type => "string")
Setting.create(:name => "max_items_per_user",  :value => "0", :setting_type => "Item", :item_type => "string")
Setting.create(:name => "items_per_page",  :value => "10", :setting_type => "Item", :item_type => "string")
Setting.create(:name => "item_approval_required",  :value => "0", :setting_type => "Item",  :item_type => "bool")
Setting.create(:name => "allow_user_registration", :value => "1", :setting_type => "User",  :item_type => "bool")
Setting.create(:name => "show_user_login", :value => "1", :setting_type => "User",  :item_type => "bool")
Setting.create(:name => "users_can_delete_items",  :value => "1", :setting_type => "Item",  :item_type => "bool")
Setting.create(:name => "caching",  :value => "0", :setting_type => "System",  :item_type => "bool")
Setting.create(:name => "enable_item_description",  :value => "1", :setting_type => "Item", :item_type => "bool")
Setting.create(:name => "enable_item_date",  :value => "1", :setting_type => "Item", :item_type => "bool")

Setting.create(:name => "display_help_sections",  :value => "0", :setting_type => "Public", :item_type => "bool")        
Setting.create(:name => "list_type",  :value => "detailed", :setting_type => "Hidden", :item_type => "string") # choices: detailed, photos, small      
Setting.create(:name => "include_child_category_items",  :value => "1", :setting_type => "Item", :item_type => "bool")        
Setting.create(:name => "allow_item_list_type_changes",  :value => "1", :setting_type => "Item", :item_type => "bool") # let the public change the item list type(via session[:list_type])
Setting.create(:name => "enable_navlinks",  :value => "1", :setting_type => "Item", :item_type => "bool")     
Setting.create(:name => "allow_private_items", :value => "1", :setting_type => "Item", :item_type => "bool")          
Setting.create(:name => "let_users_create_items", :value => "1", :setting_type => "Item", :item_type => "bool")              
Setting.create(:name => "display_popular_items",  :value => "1", :setting_type => "Item", :item_type => "bool")
Setting.create(:name => "display_item_views", :value => "1", :setting_type => "Item", :item_type => "bool")
Setting.create(:name => "email_verification_required",   :value => "0", :setting_type => "User", :item_type => "bool")    
Setting.create(:name => "allow_page_comments",  :value => "1", :setting_type => "Public", :item_type => "bool")
Setting.create(:name => "allow_public_access",  :value => "1", :setting_type => "System", :item_type => "bool")
Setting.create(:name => "opal_version",  :value => nil, :setting_type => "Hidden", :item_type => "string")
Setting.create(:name => "section_blog",   :value => "1", :setting_type => "Section", :item_type => "bool")
Setting.create(:name => "section_items",   :value => "1", :setting_type => "Section", :item_type => "bool")
Setting.create(:name => "new_user_notification",  :value => "1", :setting_type => "User", :item_type => "bool")
Setting.create(:name => "new_item_notification",  :value => "1", :setting_type => "Item", :item_type => "bool")
Setting.create(:name => "display_featured_items", :value => "1", :setting_type => "Item", :item_type => "bool")    
Setting.create(:name => "homepage_type", :value => "new_items", :setting_type => "Hidden", :item_type => "string")
Setting.create(:name => "item_page_type", :value => "summarized", :setting_type => "Hidden", :item_type => "string")
Setting.create(:name => "setup_completed", :value => "0", :item_type => "bool", :setting_type => "Hidden")   
Setting.create(:name => "locale", :value => I18n.locale.to_s, :item_type => "special", :setting_type => "Public")
Setting.create(:name => "allow_item_page_type_changes",  :value => "1", :setting_type => "Item", :item_type => "bool") 
Setting.create(:name => "allow_item_page_type_changes",  :value => "1", :setting_type => "Item", :item_type => "bool") 
Setting.create(:name => "opal_version", :value => "0.0.0", :setting_type => "Hidden", :item_type => "string")

# Create Groups
public_group = Group.new(:name => I18n.t('seeds.group.public.name'), :description => I18n.t('seeds.group.public.description'))
public_group.is_deletable = "0"
public_group.save     
users_group = Group.new(:name => I18n.t('seeds.group.users.name'), :description => I18n.t('seeds.group.users.description'))
users_group.is_deletable = "0"
users_group.save   
admin_group = Group.new(:name => I18n.t('seeds.group.admin.name'), :description => I18n.t('seeds.group.admin.description'))
admin_group.is_deletable = "0"
admin_group.save  


# Create Default Admin Account

@admin = User.new(:first_name => I18n.t('seeds.user.admin.first_name'), :last_name => I18n.t('seeds.user.admin.last_name'), :username => I18n.t('seeds.user.admin.username'), :password => I18n.t('seeds.user.admin.password'), :password_confirmation => I18n.t('seeds.user.admin.password'), :is_admin => "1", :email => I18n.t('seeds.user.admin.email'))
@admin.group_id = admin_group.id
@admin.is_admin = "1" 
@admin.is_verified = "1"     
@admin.locale = I18n.locale.to_s
@admin.save

# Create Builtin Plugins, plugin.name is not displayed name, it is used for related Plugin Class lookup, ie: "Image" => PluginImage
plugin = Plugin.create(:name => "Image", :is_enabled => "1", :is_builtin => "1")
    PluginSetting.create(:plugin_id => plugin.id, :name => "slideshow_speed",   :value => "2500", :setting_type => "System", :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_thumbnail_width",  :value => "180", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_thumbnail_height",   :value => "125", :setting_type => "Plugin",  :item_type => "string")           
    PluginSetting.create(:plugin_id => plugin.id, :name => "resize_item_images",   :value => "0", :setting_type => "Plugin",  :item_type => "bool")   
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_image_width",   :value => "500", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_image_height",  :value => "500", :setting_type => "Plugin", :item_type => "string")        
plugin = Plugin.create(:name => "Description", :is_enabled => "1", :is_builtin => "1")
plugin = Plugin.create(:name => "Feature", :is_enabled => "1", :is_builtin => "1")
plugin = Plugin.create(:name => "Link", :is_enabled => "1", :is_builtin => "1")    
plugin = Plugin.create(:name => "Review",  :is_enabled => "1", :is_builtin => "1")
    PluginSetting.create(:plugin_id => plugin.id, :name => "review_type", :value => "Stars", :item_type => "option", :options => "Stars, Slider, Number")
    PluginSetting.create(:plugin_id => plugin.id, :name => "score_min",  :value => "0",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "score_max",   :value => "5",  :item_type => "string")        
plugin = Plugin.create(:name => "Comment", :is_enabled => "1", :is_builtin => "1")    
plugin = Plugin.create(:name => "File",  :is_enabled => "1", :is_builtin => "1")
    PluginSetting.create(:plugin_id => plugin.id, :name => "login_required_for_download",   :value => "0", :setting_type => "System",  :item_type => "bool")
    PluginSetting.create(:plugin_id => plugin.id, :name => "log_downloads",  :value => "0", :setting_type => "System", :item_type => "bool")    
plugin = Plugin.create(:name => "Tag", :is_enabled => "1", :is_builtin => "1")              
plugin = Plugin.create(:name => "Discussion", :order_number => Plugin.next_order_number, :is_enabled => "1", :is_builtin => "1")



# Create Categories
Category.create(:name => I18n.t('seeds.category.uncategorized.name'), :category_id => 0, :description => I18n.t('seeds.category.uncategorized.description'))

# Create  Pages
pages = Hash.new
title = Setting.get_setting("title")
Page.create(:title => I18n.t('seeds.page.banner_top.title'), :description => I18n.t('seeds.page.banner_top.description'), :page_type => "system", :content => I18n.t('seeds.page.banner_top.content'))
Page.create(:title => I18n.t('seeds.page.banner_bottom.title'), :description => I18n.t('seeds.page.banner_bottom.description'), :page_type => "system", :content => I18n.t('seeds.page.banner_bottom.content'))
#Page.create(:title => I18n.t('seeds.page.terms_of_service.title'), :description => I18n.t('seeds.page.terms_of_service.description'), :page_type => "system", :content => I18n.t('seeds.page.terms_of_service.content'))
# Add a new page that will show when a user is creating a new item.
Page.create(:title => I18n.t('seeds.page.new_item.title'), :description => I18n.t('seeds.page.new_item.description'), :page_type => "system", :content => I18n.t('seeds.page.new_item.content'))
# Create Email Footer Page
Page.create(:title => I18n.t('seeds.page.email_footer.title'), :description => I18n.t('seeds.page.email_footer.description'), :page_type => "system", :content => I18n.t('seeds.page.email_footer.content'))
# Create Homepage Sidebar Page
Page.create(:title => I18n.t('seeds.page.home_page_sidebar.title'), :description => I18n.t('seeds.page.home_page_sidebar.description'), :page_type => "system", :content => I18n.t('seeds.page.home_page_sidebar.content'))
Page.create(:title => I18n.t('seeds.page.website_top.title'), :description => I18n.t('seeds.page.website_top.description'), :page_type => "system", :content => I18n.t('seeds.page.website_top.content'))
Page.create(:title => I18n.t('seeds.page.website_bottom.title'), :description => I18n.t('seeds.page.website_bottom.description'), :page_type => "system", :content => I18n.t('seeds.page.website_bottom.content'))
Page.create(:title => I18n.t('seeds.page.category_column.title'), :description => I18n.t('seeds.page.category_column.description'), :page_type => "system", :content => I18n.t('seeds.page.category_column.content'))

pages[:home] = Page.new(:title => I18n.t('seeds.page.home.title'), :description => I18n.t('seeds.page.home.description'), :page_type => "public", :content => I18n.t('seeds.page.home.content'))
pages[:home].name = "home"
pages[:home].locked = true
pages[:home].deletable = false
pages[:home].save

pages[:items] = Page.new(:title => I18n.t('seeds.page.items.title'), :description => I18n.t('seeds.page.items.description'), :page_type => "public", :content => I18n.t('seeds.page.items.content'))
pages[:items].name = "items"
pages[:items].locked = true
pages[:items].title_editable = false
pages[:items].deletable = false
pages[:items].save 

pages[:blog] = Page.new(:title => I18n.t('seeds.page.blog.title'), :description => I18n.t('seeds.page.blog.description'), :page_type => "public", :content => I18n.t('seeds.page.blog.content'))
pages[:blog].name = "blog"
pages[:blog].locked = true
pages[:blog].deletable = false
pages[:blog].save

pages[:tos] = Page.new(:title => I18n.t('seeds.page.terms_of_service.title'), :description => I18n.t('seeds.page.terms_of_service.description'), :page_type => "public", :content => I18n.t('seeds.page.terms_of_service.content'))
pages[:tos].deletable = false
pages[:tos].name = "terms_of_service"
pages[:tos].display_in_menu = false
pages[:tos].locked = true
pages[:tos].save

pages[:contact_us] = Page.new(:name => "contact_us", :title => I18n.t('seeds.page.contact_us.title'), :description => I18n.t('seeds.page.contact_us.description'), :page_type => "public", :content => I18n.t('seeds.page.contact_us.content'))
pages[:contact_us].locked = true
pages[:contact_us].deletable = false
pages[:contact_us].save



# Create Default Group Plugin Permissions
GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", Group.public.id, Plugin.find_by_name("Comment").id]).update_attribute(:can_create, "1")  
GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", Group.user.id, Plugin.find_by_name("Comment").id]).update_attribute(:can_create, "1")  
GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", Group.user.id, Plugin.find_by_name("Review").id]).update_attribute(:can_create, "1")  


 
puts " #{I18n.t('single.done')}."

# Sample Data
if ENV["PROMPTS"].downcase == "false" # skip prompt
  puts I18n.t('label.skipping_prompt') 
  install_sample_data = "y"
else # show prompt    
  install_sample_data = prompt(I18n.t('confirm.install_sample_data'), "Y").downcase 
end

if (install_sample_data == "y" || install_sample_data == "yes")   
  print I18n.t('label.installing') 
  #Create Verified user
  @user = User.new(:first_name => I18n.t('sample_data.users.test.first_name'), :last_name => I18n.t('sample_data.users.test.last_name'), :username => I18n.t('sample_data.users.test.username'), :password => I18n.t('sample_data.users.test.password'), :password_confirmation => I18n.t('sample_data.users.test.password'), :email => I18n.t('sample_data.users.test.email'))
  @user.is_verified = "1" # verify them(attr_protected otherwise)
  @user.save
  
  #Create Unverified user
  @unverified = User.create(:first_name => I18n.t('sample_data.users.unverified.first_name'), :last_name => I18n.t('sample_data.users.unverified.last_name'), :username => I18n.t('sample_data.users.unverified.username'), :password => I18n.t('sample_data.users.unverified.password'), :password_confirmation => I18n.t('sample_data.users.unverified.password'), :email => I18n.t('sample_data.users.unverified.email'))

  #Create User Messages
  msg = UserMessage.new(:message => I18n.t('sample_data.messages.unread.text'))
  msg.from_user_id = @admin.id
  msg.user_id = @user.id
  msg.to_user_id = @user.id
  msg.save
  msg = UserMessage.new(:message => I18n.t('sample_data.messages.read.text'), :is_read => "1")
  msg.from_user_id = @admin.id
  msg.user_id = @user.id
  msg.to_user_id = @user.id
  msg.save    
  msg = UserMessage.new(:message => I18n.t('sample_data.messages.reply.text'), :reply_to_message_id => 1)
  msg.from_user_id = @user.id
  msg.user_id = @admin.id
  msg.to_user_id = @admin.id  
  msg.save     
  
  # Create Test Item
  item1 = Item.new(:name => I18n.t('sample_data.items.simple.name'), :description => I18n.t('sample_data.items.simple.description'))
  item1.user_id = @admin.id
  item1.is_public = "1"
  item1.featured = true
  item1.is_approved = "1"
  item1.save
  
  item2 = Item.new(:name => I18n.t('sample_data.items.long_name.name'), :description => I18n.t('sample_data.items.long_name.description'))
  item2.user_id = @user.id
  item2.is_public = "1"
  item2.is_approved = "1"
  item2.save
  
  item3 = Item.new(:name => I18n.t('sample_data.items.unapproved.name'), :description => I18n.t('sample_data.items.unapproved.description'))
  item3.user_id = @user.id
  item3.save
  
  
  # Create Plugins 
  #plugin = PluginImage.new(:url => "/images/item_images/1/example_image_1.png", :thumb_url => "/images/item_images/1/thumb_example_image_1.png", :pinky_url => "/images/item_images/1/pinky_example_image_1.png", :description => I18n.t('sample_data.plugins.images.simple.description'))
  #plugin.item_id = item1.id 
  #plugin.user_id = @user.id 
  #plugin.save
  
  @plugin = PluginDescription.new(:title => I18n.t('sample_data.plugins.description.simple.title'), :content => I18n.t('sample_data.plugins.description.simple.content'))
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save
  
  # Create  Features
  @plugin = PluginFeature.new(:name => I18n.t('sample_data.plugins.features.price.name'), :order_number => 0)
  @plugin.save    
      @plugin_feature_value = PluginFeatureValue.new(:value => I18n.t('sample_data.plugins.features.price.value'))
      @plugin_feature_value.plugin_feature_id = @plugin.id
      @plugin_feature_value.is_approved = "1"        
      @plugin_feature_value.item_id = item1.id
      @plugin_feature_value.user_id = @user.id 
      @plugin_feature_value.save    
        
  @plugin = PluginFeature.new(:name => I18n.t('sample_data.plugins.features.size.name'), :order_number => 1, :feature_type => "option")    
  @plugin.save
  PluginFeatureValueOption.create(:value => I18n.t('sample_data.plugins.features.size.option_small'), :plugin_feature_id => @plugin.id)
  PluginFeatureValueOption.create(:value => I18n.t('sample_data.plugins.features.size.option_medium'), :plugin_feature_id => @plugin.id)
  PluginFeatureValueOption.create(:value => I18n.t('sample_data.plugins.features.size.option_large'), :plugin_feature_id => @plugin.id)  
      @plugin_feature_value = PluginFeatureValue.new(:value => I18n.t('sample_data.plugins.features.size.option_large'))
      @plugin_feature_value.plugin_feature_id = @plugin.id
      @plugin_feature_value.is_approved = "1"        
      @plugin_feature_value.item_id = item1.id
      @plugin_feature_value.user_id = @user.id 
      @plugin_feature_value.save        
  
  @plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.date.name'), :order_number => 1, :feature_type => "date")    
  @plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.rank.name'), :order_number => 1, :feature_type => "slider", :min => 1, :max => 10)    
  @plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.score.name'), :order_number => 1, :feature_type => "stars", :max => 5)    
  @plugin = PluginFeature.create(:name => I18n.t('sample_data.plugins.features.is_this_awesome.name'), :order_number => 1, :feature_type => "yesno", :max => 5)    

  
  
  @plugin = PluginReview.new(:review_score => 5, :review => I18n.t('sample_data.plugins.reviews.simple.text'))
  @plugin.item_id = item1.id
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save    
  
  @plugin = PluginComment.new(:comment => I18n.t('sample_data.plugins.comments.simple.text'))
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save    
  
  @plugin = PluginLink.new(:title => I18n.t('sample_data.plugins.links.simple.title'), :url => "http://www.hulihanapplications.com")
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"
  @plugin.user_id = @user.id 
  @plugin.save    
  
  @plugin = PluginTag.new(:name => I18n.t('sample_data.plugins.tags.simple.name'))
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save   
 
  tag = PluginTag.create(:name => I18n.t('sample_data.plugins.tags.cool.name'), :item_id => item1.id)
  tag.is_approved = "1"
  tag.save
  tag = PluginTag.create(:name => I18n.t('sample_data.plugins.tags.cool.name'), :item_id => item2.id)
  tag.is_approved = "1"
  tag.save

  # Sample Discussion
  discussion = PluginDiscussion.new(:item_id => 1, :user_id => @user.id, :title => I18n.t('sample_data.plugins.discussions.simple.title'), :description => I18n.t('sample_data.plugins.discussions.simple.description'))
  discussion.is_approved = "1"
  discussion.save

  discussion_post = PluginDiscussionPost.create(:item_id => 1, :user_id => @user.id, :plugin_discussion_id => discussion.id, :post => I18n.t('sample_data.plugins.discussions.simple.post'))

  # Create Public Page
  pages[:about] = Page.create(:title => I18n.t('sample_data.pages.about.title'), :description => I18n.t('sample_data.pages.about.description'), :page_type => "public", :content => I18n.t('sample_data.pages.about.content'))
  pages[:more_about] = Page.create(:title => I18n.t('sample_data.pages.more_about.title'), :page_id => pages[:about].id, :description => I18n.t('sample_data.pages.more_about.description'), :page_type => "public", :content => I18n.t('sample_data.pages.more_about.content'))

  
  # Create Blog Post
  blog_page = Page.new(:title => I18n.t('sample_data.pages.blog_post.title'), :content => I18n.t('sample_data.pages.blog_post.content'), :page_type => "blog")
  blog_page.save
  
  # Extra Categories
  Category.create(:name => I18n.t('sample_data.categories.uncategorized_child.name'), :category_id => 1, :description => I18n.t('sample_data.categories.uncategorized_child.description'))
  Category.create(:name => I18n.t('sample_data.categories.uncategorized_grand_child.name'), :category_id => 2, :description => I18n.t('sample_data.categories.uncategorized_grand_child.description'))
  
  puts " #{I18n.t('single.done')}."
end 

puts "\n" + I18n.t("notice.item_install_success", :item => I18n.t("name")) + "\n"
puts I18n.t("label.login_as", :username => I18n.t('seeds.user.admin.username'), :password => I18n.t('seeds.user.admin.password'))
Log.create(:log => I18n.t("notice.item_install_success", :item => I18n.t("name")), :log_type => "system") # Log Install

Setting.find_by_name("opal_version").update_attribute(:value, "0.7.2") # Update Version    

