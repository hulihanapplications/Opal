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



# Create Global Settings
Setting.create(:name => "item_name", :value => "Item", :setting_type => "Item", :item_type => "string")
Setting.create(:name => "item_name_plural",  :value => "Items", :setting_type => "Item",  :item_type => "string")
Setting.create(:name => "site_title",  :value => "My Opal Website", :setting_type => "Public",  :item_type => "string")
Setting.create(:name => "site_keywords",  :value => "Opal", :setting_type => "Public",  :item_type => "string")
Setting.create(:name => "site_description",  :value => "The Free, Open Source, Item Management System. List Anything!", :setting_type => "Public",  :item_type => "string")
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
Setting.create(:name => "locale", :value => "en", :item_type => "special", :setting_type => "Public")
Setting.create(:name => "allow_item_page_type_changes",  :value => "1", :setting_type => "Item", :item_type => "bool") 
Setting.create(:name => "allow_item_page_type_changes",  :value => "1", :setting_type => "Item", :item_type => "bool") 
Setting.create(:name => "opal_version", :value => "0.0.0", :setting_type => "Hidden", :item_type => "string")

# Create Builtin Plugins
plugin = Plugin.create(:name => "Image", :is_enabled => "1", :is_builtin => "1")
    PluginSetting.create(:plugin_id => plugin.id, :name => "slideshow_speed",   :value => "2500", :setting_type => "System", :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_thumbnail_width",  :value => "180", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_thumbnail_height",   :value => "125", :setting_type => "Plugin",  :item_type => "string")           
    PluginSetting.create(:plugin_id => plugin.id, :name => "resize_item_images",   :value => "0", :setting_type => "Plugin",  :item_type => "bool")   
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_image_width",   :value => "500", :setting_type => "Plugin",  :item_type => "string")
    PluginSetting.create(:plugin_id => plugin.id, :name => "item_image_height",  :value => "500", :setting_type => "Plugin", :item_type => "string")        
plugin = Plugin.create(:name => "Description",    :is_enabled => "1", :is_builtin => "1")
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
Category.create(:name => "Uncategorized", :category_id => 0, :description => "Things that are just too cool to fit into one category.")

# Create  Pages
title = Setting.get_setting("title")
Page.create(:title => "Banner Top", :description => "Any content added here will show at the top of your site. Useful for ad banners and javascript.", :page_type => "system")
Page.create(:title => "Banner Bottom", :description => "Any content added here will show at the bottom of your site. Useful for ad banners and javascript.", :page_type => "system")
Page.create(:title => "Main Home Page", :description => "The Main Home Page of your site.", :page_type => "system", :content => "<div class=\"box_2\" style=\"margin-bottom:5px\">\r\n<h1 class=\"title\">Welcome!</h1>Welcome to Opal. First time using Opal? No problem. Start by reading the <b>Getting Started</b> section.<br><br><h2 class=\"title\">Change this Section</h2>\r\n<div class=\"spacer\"></div>After you log in, Click on the <strong>admin Tab</strong>, then Click on the <strong>Pages Tab</strong>. In the <strong>System Pages Section</strong>, click on the edit icon next to the page: <span style=\"text-decoration: underline;\">Main Home Page</span>. That's all there is to it!</div>")
#Page.create(:title => "Terms of Service", :description => "The Terms of Service for new users.", :page_type => "system", :content => "<h1>Terms of Service</h1>By joining this site, you agree not to add or submit any damaging or offensive content, including by not limited to: pornography, any malicious software or files, violent or hateful images, etc.<br><br>You also agree not to submit any content that is either stolen, plagiarized, or otherwise listed without the consent of the copyright holder.")
# Add a new page that will show when a user is creating a new item.
Page.create(:title => "New Item", :description => "This page appears when a User is creating a new item.", :page_type => "system", :content => "")
# Create Email Footer Page
Page.create(:title => "Email Footer", :description => "This appears at the bottom of any automated email.", :page_type => "system", :content => "This is an automated email sent to you by #{Setting.get_setting("site_title")}. Please do not reply.")
# Create Homepage Sidebar Page
Page.create(:title => "Home Page Sidebar", :description => "This page appears in the sidebar of the homepage.", :page_type => "system", :content => "<div class=\"box_2\" style=\"margin-bottom:5px\">\r\n<h1 class=\"title\">Getting Started</h1>To get started, Log in with the username: <strong>admin</strong> and the password: <strong>admin. </strong>\r\n<br><br><h2 class=\"title\">First things First</h2>\r\n <div class=\"spacer\"></div>To start, you might want to change the name of the items you're going to be listing. To do this, log in to your account, Click on the <b>admin</b> tab, then the <b>configure</b> tab. Under the <b>Items</b> subtab, you can change the name of the items you're listing by changing the <b>Item Name</b> and <b>Plural Item Name</b> values.<br><br><h2 class=\"title\">Change this Section</h2>\r\n<div class=\"spacer\"></div>After you log in, Click on the <strong>admin Tab</strong>, then Click on the <strong>Pages Tab</strong>. In the <strong>System Pages Section</strong>, click on the edit icon next to the page: <span style=\"text-decoration: underline;\">Home Page Sidebar</span>. That's all there is to it!<br><br><h2 class=\"title\">Need Any More Help?</h2><div class=\"spacer\"></div>If you need any more help with Opal, check out the <a href=\"http://www.hulihanapplications.com/projects/opal_guide\" onclick=\"window.open(&quot;http://dev.hulihanapplications.com/wiki/opal&quot;, &quot;&quot;, &quot;resizable=yes, location=no, width=400, height=640, menubar=no, status=no, scrollbars=yes&quot;); return false;\"><b>Opal User Guide</b></a> for help on using Opal.</div>")
Page.create(:title => "Website Top", :description => "Shown at the very very top of the website.", :page_type => "system", :content => "")
Page.create(:title => "Website Bottom", :description => "Shown at the very very bottom of the website.", :page_type => "system", :content => "")
Page.create(:title => "Category Column", :description => "This page appears below the category menu.", :page_type => "system", :content => "")


tos = Page.new(:name => "terms_of_service", :title => "Terms of Service", :description => "The Terms of Service for people using this website.", :page_type => "public", :content => "<h1>Terms of Service</h1>By joining this site, you agree not to add or submit any damaging or offensive content, including by not limited to: pornography, any malicious software or files, violent or hateful images, etc.<br><br>You also agree not to submit any content that is either stolen, plagiarized, or otherwise listed without the consent of the copyright holder.")
tos.deletable = false
tos.display_in_menu = false
tos.locked = true
tos.save

contact_us = Page.new(:name => "contact_us", :title => "Contact Us", :description => "This page helps people get in touch with you.", :page_type => "public", :content => "<div align=center style=\"margin-bottom:10px\">\r\n<h2 class=\"title\">Contact Us</h2><hr> Feel free to contact us about anything!</div>")
contact_us.locked = true
contact_us.deletable = false
contact_us.save

# Create Groups
public_group = Group.new(:name => "The Public", :description => "People visiting your site that aren't logged in.")
public_group.is_deletable = "0"
public_group.save     
users_group = Group.new(:name => "Regular Users", :description => "Regular Users that have signed up at your site.")
users_group.is_deletable = "0"
users_group.save   
admin_group = Group.new(:name => "Admins", :description => "Supreme Masters. They can access and do anything.")
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
  item1 = Item.new(:name => "Test Item A", :description => "This is a test description")
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
  Page.create(:title => "About", :description => "All about us.", :page_type => "public", :content => "<div class=\"box_2\"><h1>What is Opal?</h1>Opal is a Ruby on Rails Item Management Application. Well, what kind of items can you <b>manage</b>? Anything! Bicycles, homes for sale, banana vendors, etc. can all be managed and organized by Opal.</div>")
  
  #page = Page.new(:title => "Example Page", :content => "This is an example public page!", :page_type => "public")
  #page.save
  
  # Create Blog Post
  blog_page = Page.new(:title => "First Post", :content => "This is the first blog post!", :page_type => "blog")
  blog_page.save
  
  # Extra Categories
  Category.create(:name => "Uncategorized Child", :category_id => 1, :description => "Things that are just too cool to fit into one category.")
  Category.create(:name => "Uncategorized GrandChild", :category_id => 2, :description => "Things that are just too cool to fit into one category.")
  
  puts "Done."
end 


Setting.find_by_name("opal_version").update_attribute(:value, "0.7.0") # Update Version    
