# This file creates required & sample data for new installations. 

ENV["PROMPTS"] ||= "TRUE" # turn prompts on by default    

def prompt(msg, default_value = "") # prompt user and get value
  if default_value != ""
    print msg + " (default: #{default_value}) "
  else
    print msg + " "
  end 
  entered_value = STDIN.gets  
  entered_value = entered_value.chomp # strip input of newline/carriage return
  entered_value = default_value if entered_value == "" # if they didn't 
  return entered_value
end  

# Required Data
print "Installing Required Data..."

# Defining locale 
if ENV['LOCALE'].nil?
	I18n.locale = "en"
else
	I18n.locale = ENV['LOCALE']
end

# Create Global Settings
Setting.create(:name => "item_name", :value => I18n.t('seeds.setting.item_name'), :setting_type => "Item", :item_type => "string")
Setting.create(:name => "item_name_plural",  :value => I18n.t('seeds.setting.item_name_plural'), :setting_type => "Item",  :item_type => "string")
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

# Create Builtin Plugins
plugin = Plugin.create(:name => I18n.t('seeds.plugin.image'), :is_enabled => "1", :is_builtin => "1")
    PluginSetting.create(:plugin_id => plugin.id, :name => "slideshow_speed",   :value => "2500", :setting_type => "System", :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_thumbnail_width",  :value => "180", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_thumbnail_height",   :value => "125", :setting_type => "Plugin",  :item_type => "string")           
    PluginSetting.create(:plugin_id => plugin.id, :name => "resize_item_images",   :value => "0", :setting_type => "Plugin",  :item_type => "bool")   
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_image_width",   :value => "500", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_image_height",  :value => "500", :setting_type => "Plugin", :item_type => "string")        
plugin = Plugin.create(:name => I18n.t('seeds.plugin.description'),    :is_enabled => "1", :is_builtin => "1")
plugin = Plugin.create(:name => I18n.t('seeds.plugin.feature'), :is_enabled => "1", :is_builtin => "1")
plugin = Plugin.create(:name => I18n.t('seeds.plugin.link'), :is_enabled => "1", :is_builtin => "1")    
plugin = Plugin.create(:name => I18n.t('seeds.plugin.review'),  :is_enabled => "1", :is_builtin => "1")
    PluginSetting.create(:plugin_id => plugin.id, :name => "review_type", :value => "Stars", :item_type => "option", :options => "Stars, Slider, Number")
    PluginSetting.create(:plugin_id => plugin.id, :name => "score_min",  :value => "0",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "score_max",   :value => "5",  :item_type => "string")        
plugin = Plugin.create(:name => I18n.t('seeds.plugin.comment'), :is_enabled => "1", :is_builtin => "1")    
plugin = Plugin.create(:name => I18n.t('seeds.plugin.file'),  :is_enabled => "1", :is_builtin => "1")
    PluginSetting.create(:plugin_id => plugin.id, :name => "login_required_for_download",   :value => "0", :setting_type => "System",  :item_type => "bool")
    PluginSetting.create(:plugin_id => plugin.id, :name => "log_downloads",  :value => "0", :setting_type => "System", :item_type => "bool")    
plugin = Plugin.create(:name => I18n.t('seeds.plugin.tag'), :is_enabled => "1", :is_builtin => "1")              
plugin = Plugin.create(:name => I18n.t('seeds.plugin.discussion'), :order_number => Plugin.next_order_number, :is_enabled => "1", :is_builtin => "1")



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

# Group Plugin Permissions 
for plugin in Plugin.find(:all)
  GroupPluginPermission.create(:group_id => users_group.id, :plugin_id => plugin.id, :can_read => "1") # turn on read permissions for users
  GroupPluginPermission.create(:group_id => public_group.id, :plugin_id => plugin.id, :can_read => "1") # turn on read permissions for the public   
end 


# Create Default Group Plugin Permissions
GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", public_group.id, Plugin.find_by_name("Comment").id]).update_attribute(:can_create, "1")  
GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", users_group.id, Plugin.find_by_name("Comment").id]).update_attribute(:can_create, "1")  
GroupPluginPermission.find(:first, :conditions => ["group_id = ? and plugin_id = ?", users_group.id, Plugin.find_by_name("Review").id]).update_attribute(:can_create, "1")  


# Create Default Admin Account
@admin = User.new(:first_name => "Bob", :last_name => "Jones", :username => "admin", :password => "admin", :is_admin => "1", :email => "admin@test.com")
@admin.group_id = admin_group.id
@admin.is_admin = "1" 
@admin.is_verified = "1"     
@admin.locale = I18n.locale.to_s
@admin.save



 
puts "Done."

# Sample Data
if ENV["PROMPTS"].downcase == "false" # skip prompt
  puts "Skipping Prompt..." 
  install_sample_data = "y"
else # show prompt    
  install_sample_data = prompt("Install Sample Data? (Example Items, Categories, Users)", "Y").downcase 
end

if (install_sample_data == "y" || install_sample_data == "yes")   
  print "Installing Sample Data..."
  #Create Verified user
  @user = User.new(:first_name => "John", :last_name => "Doe", :username => "test", :password => "test", :email => "test@test.com")
  @user.is_verified = "1" # verify them(attr_protected otherwise)
  @user.save
  
  #Create Unverified user
  User.create(:first_name => "Bill", :last_name => "McGrew", :username => "unverified", :password => "unverified", :email => "test2@test.com")

  # English locale user
  @user = User.new(:first_name => "English", :last_name => "English", :username => "english", :password => "english", :email => "english@test.com", :group_id => admin_group.id, :is_admin => "1")
  @user.is_verified = "1"
  @user.locale = "en"
  @user.save

  # Russian locale user
  @user = User.new(:first_name => "Russian", :last_name => "Русский", :username => "russian", :password => "russian", :email => "russian@test.com",  :group_id => admin_group.id, :is_admin => "1")
  @user.is_verified = "1"
  @user.locale = "ru"
  @user.save

   #Create User Messages
  msg = UserMessage.new(:message => "Test message(unread) to test from admin.")
  msg.from_user_id = @admin.id
  msg.user_id = @user.id
  msg.to_user_id = @user.id
  msg.save
  msg = UserMessage.new(:message => "Test message(read) to test from admin.", :is_read => "1")
  msg.from_user_id = @admin.id
  msg.user_id = @user.id
  msg.to_user_id = @user.id
  msg.save    
  msg = UserMessage.new(:message => "Test Message from Test to Admin.", :reply_to_message_id => 1)
  msg.from_user_id = @user.id
  msg.user_id = @admin.id
  msg.to_user_id = @admin.id  
  msg.save     
  
  # Create Test Item
  item1 = Item.new(:name => "Test Item A", :description => "This is a test description.")
  item1.user_id = @admin.id
  item1.is_public = "1"
  item1.featured = true
  item1.is_approved = "1"
  item1.save
  
  item2 = Item.new(:name => "Test Item B(with a Really Really Really Really Really Long Name).", :description => "This is a test description. It is really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really long.")
  item2.user_id = @user.id
  item2.is_public = "1"
  item2.is_approved = "1"
  item2.save
  
  item3 = Item.new(:name => "Test Item C (Unapproved)", :description => "This is a test description. This item is neither approved nor Public.")
  item3.user_id = @user.id
  item3.save
  
  
  # Create Plugins 
  #plugin = PluginImage.new(:url => "/images/item_images/1/example_image_1.png", :thumb_url => "/images/item_images/1/thumb_example_image_1.png", :pinky_url => "/images/item_images/1/pinky_example_image_1.png", :description => "A sample image.")
  #plugin.item_id = item1.id 
  #plugin.user_id = @user.id 
  #plugin.save
  
  @plugin = PluginDescription.new(:title => "A Wonderful Item!", :content => "This item is very wonderful.<br><br>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc tempus pellentesque nibh. Cras suscipit, arcu at porttitor porttitor, neque ligula aliquam metus, sit amet egestas velit nulla et eros. Sed ac erat eget eros pellentesque feugiat. Nunc sagittis dolor sit amet velit. Nulla quam. Donec ultrices lacus at risus. Sed in diam eget tortor sagittis congue. Sed vel odio. Integer bibendum purus in nibh. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis neque dolor, posuere posuere, volutpat ultrices, sollicitudin elementum, nulla. Morbi interdum urna vitae purus. Suspendisse vitae quam eu diam hendrerit dictum. Maecenas dignissim, mi ut lacinia auctor, mauris sem porttitor lectus, vel consectetur nulla est non neque. Suspendisse hendrerit massa non nisl.<br><br>Cras tortor. Aenean sed tortor. Maecenas orci lectus, viverra nec, molestie nec, pharetra vitae, massa. Cras euismod vestibulum augue. Morbi viverra nisl in purus. Etiam rhoncus dignissim erat. Vivamus a lorem in metus molestie porta. Curabitur nibh. Cras mattis justo ac felis. Morbi commodo, nulla id eleifend eleifend, nisi ligula sollicitudin est, a interdum lorem massa in leo. Suspendisse sit amet enim id nunc feugiat feugiat. Ut euismod neque. Etiam convallis faucibus dui. Cras aliquam ligula eu mauris. Cras vestibulum neque vel nisl. In arcu risus, hendrerit ac, laoreet sit amet, blandit at, nisl. Ut elementum eleifend lectus.<br><br>Nunc molestie enim. Nulla nec diam. Maecenas vel mauris. Pellentesque sit amet sem ac metus egestas tempor. Integer nibh. Donec sed velit a justo posuere sodales. Vestibulum molestie porttitor metus. Ut eleifend enim a lacus. Aliquam pretium dignissim velit. Ut euismod eros nec justo. Mauris pharetra. Nunc imperdiet elementum dui. Nunc et urna. Mauris at odio. ")
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save
  
  # Create  Features
  @plugin = PluginFeature.new(:name => "Price", :order_number => 0)
  @plugin.save    
      @plugin_feature_value = PluginFeatureValue.new(:value => "$200.00 USD")
      @plugin_feature_value.plugin_feature_id = @plugin.id
      @plugin_feature_value.is_approved = "1"        
      @plugin_feature_value.item_id = item1.id
      @plugin_feature_value.user_id = @user.id 
      @plugin_feature_value.save    
        
  @plugin = PluginFeature.new(:name => "Size", :order_number => 1, :feature_type => "option")    
  @plugin.save
  PluginFeatureValueOption.create(:value => "Small", :plugin_feature_id => @plugin.id)
  PluginFeatureValueOption.create(:value => "Medium", :plugin_feature_id => @plugin.id)
  PluginFeatureValueOption.create(:value => "Large", :plugin_feature_id => @plugin.id)  
      @plugin_feature_value = PluginFeatureValue.new(:value => "Large")
      @plugin_feature_value.plugin_feature_id = @plugin.id
      @plugin_feature_value.is_approved = "1"        
      @plugin_feature_value.item_id = item1.id
      @plugin_feature_value.user_id = @user.id 
      @plugin_feature_value.save        
  
  @plugin = PluginFeature.create(:name => "Date", :order_number => 1, :feature_type => "date")    
  @plugin = PluginFeature.create(:name => "Rank", :order_number => 1, :feature_type => "slider", :min => 1, :max => 10)    
  @plugin = PluginFeature.create(:name => "Score", :order_number => 1, :feature_type => "stars", :max => 5)    
  @plugin = PluginFeature.create(:name => "Is this awesome?", :order_number => 1, :feature_type => "yesno", :max => 5)    

  
  
  @plugin = PluginReview.new(:review_score => 5, :review => "I really like this!")
  @plugin.item_id = item1.id
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save    
  
  @plugin = PluginComment.new(:comment => "Thanks for sharing this with us!")
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save    
  
  @plugin = PluginLink.new(:title => "Item Website", :url => "http://www.hulihanapplications.com")
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"
  @plugin.user_id = @user.id 
  @plugin.save    
  
  @plugin = PluginTag.new(:name => "Most Current")
  @plugin.item_id = item1.id 
  @plugin.is_approved = "1"    
  @plugin.user_id = @user.id 
  @plugin.save   
 
  tag = PluginTag.create(:name => "Cool", :item_id => item1.id)
  tag.is_approved = "1"
  tag.save
  tag = PluginTag.create(:name => "Cool", :item_id => item2.id)
  tag.is_approved = "1"
  tag.save

  # Sample Discussion
  discussion = PluginDiscussion.new(:item_id => 1, :user_id => 1, :title => "Test Discussion", :description => "This is a test discussion. Feel free to delete this.")
  discussion.is_approved = "1"
  discussion.save

  discussion_post = PluginDiscussionPost.create(:item_id => 1, :user_id => 1, :plugin_discussion_id => discussion.id, :post => "This is a test post.")
    
  
  # Create Public Page
  pages[:about] = Page.create(:title => "About", :description => "All about us.", :page_type => "public", :content => "<div class=\"box_2\"><h1>What is Opal?</h1>Opal is a Ruby on Rails Item Management Application. Well, what kind of items can you <b>manage</b>? Anything! Bicycles, homes for sale, banana vendors, etc. can all be managed and organized by Opal.</div>")
    pages[:more_about] = Page.create(:title => "More About Us", :page_id => pages[:about].id, :description => "", :page_type => "public", :content => "Here's more info about us.")

  
  # Create Blog Post
  blog_page = Page.new(:title => "First Post", :content => "This is the first blog post!", :page_type => "blog")
  blog_page.save
  
  # Extra Categories
  Category.create(:name => "Uncategorized Child", :category_id => 1, :description => "Things that are just too cool to fit into one category.")
  Category.create(:name => "Uncategorized GrandChild", :category_id => 2, :description => "Things that are just too cool to fit into one category.")
  
  puts "Done."
end 


Setting.find_by_name("opal_version").update_attribute(:value, "0.7.2") # Update Version    
