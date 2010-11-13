class CreateSampleData < ActiveRecord::Migration

  # Dave: this migration happens last, because many models are created at once, when you first create a story, for instance, and if the db table doesn't exist yet, the migration will fail.
  def self.up
    @admin = User.new(:first_name => "Bob", :last_name => "Jones", :username => "admin", :password => "admin", :is_admin => "1", :email => "admin@test.com")
    @admin.is_admin = "1" 
    @admin.is_verified = "1"     
    @admin.save

    #Create Verified user
    @user = User.new(:first_name => "John", :last_name => "Doe", :username => "test", :password => "test", :email => "test@test.com")
    @user.is_verified = "1" # verify them(attr_protected otherwise)
    @user.save
   
    #Create Unverified user
    User.create(:first_name => "Bill", :last_name => "McGrew", :username => "unverified", :password => "unverified", :email => "test2@test.com")

    #Create User Messages
    msg = UserMessage.new(:message => "Test message(unread) to test from admin.")
    msg.from_user_id = 1
    msg.user_id = 2
    msg.save
    msg = UserMessage.new(:message => "Test message(read) to test from admin.", :is_read => "1")
    msg.from_user_id = 1
    msg.user_id = 2
    msg.save    
    msg = UserMessage.new(:message => "Test Message from Test to Admin.", :reply_to_message_id => 1)
    msg.from_user_id = 2
    msg.user_id = 1
    msg.save     
    
    # Create Test Item
    item1 = Item.new(:name => "Test Item A", :description => "This is a test description")
    item1.user_id = 1
    item1.is_public = "1"
    item1.is_approved = "1"
    item1.save

    item2 = Item.new(:name => "Test Item B(with a Really Really Really Really Really Long Name).", :description => "This is a test description. It is really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really long.")
    item2.user_id = 2
    item2.is_public = "1"
    item2.is_approved = "1"
    item2.save
    
    item3 = Item.new(:name => "Test Item C (Unapproved)", :description => "This is a test description. This item is neither approved nor Public.")
    item3.user_id = 2
    item3.save
    
    # Create Plugin Containers
    Plugin.create(:name => "Image", :title => "Image", :description => "Images for Items.", :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Description", :title => "Description", :description => "Large Text Descriptions For Items.",   :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Feature", :title => "Feature", :description => "These are atttributes that an several items might have. For example: a house would have a feature called <b>price</b>.", :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Link", :title => "Link", :description => "A link for an item. This can be a link to a page for more information about the item, a website, or a file location.", :is_enabled => "1", :is_builtin => "1")    
    Plugin.create(:name => "Review", :title => "Review", :description => "Item Reviews from Users. Reviews have scores that are tallied up to rate the value an item.",  :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Comment", :title => "Comment", :description => "Item Comments from Users. Comments are just notes about the item.", :is_enabled => "1", :is_builtin => "1")    
    Plugin.create(:name => "File", :title => "File", :description => "Files uploaded for a particular item. Useful for Software, PDFs, Images, etc.", :is_enabled => "1", :is_builtin => "1")
    Plugin.create(:name => "Tag", :title => "Tag", :description => "Tags/Labels for an Item. This is another way to organize items besides by categories. All tags in the System are grouped together. You can add as many as you want.", :is_enabled => "1", :is_builtin => "1")    
    
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
    
=begin    
    @plugin = PluginFeature.new(:name => "Price", :order_number => 0)
    @plugin.save
    
        @plugin_feature_value = PluginFeatureValue.new(:value => "$200.00 USD")
        @plugin_feature_value.plugin_feature_id = @plugin.id
        @plugin_feature_value.is_approved = "1"        
        @plugin_feature_value.item_id = item1.id
        @plugin_feature_value.user_id = @user.id 
        @plugin_feature_value.save    
        
    @plugin = PluginFeature.new(:name => "Size", :order_number => 1)    
    @plugin.save

        @plugin_feature_value = PluginFeatureValue.new(:value => "Large")
        @plugin_feature_value.plugin_feature_id = @plugin.id
        @plugin_feature_value.is_approved = "1"        
        @plugin_feature_value.item_id = item1.id
        @plugin_feature_value.user_id = @user.id 
        @plugin_feature_value.save        
=end    
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
  
     # Create Global Settings
     Setting.create(:name => "item_name", :title => "Item Name", :value => "Item", :setting_type => "Item", :description => "This is the <b>singular</b> name of the items on your site, so if you want to show people homes, this would be <b>home</b>.", :item_type => "string")
     Setting.create(:name => "item_name_plural", :title => "Plural Item Name",  :value => "Items", :setting_type => "Item", :description => "This is the <b>plural</b> name of the items on your site, so if you want to show people homes, this would be <b>homes</b>.", :item_type => "string")
     Setting.create(:name => "site_title", :title => "Title of Your Site",  :value => "My Opal Website", :setting_type => "Public", :description => "The Title of your Site. You would see this at the very top of your browser window.", :item_type => "string")
     Setting.create(:name => "site_keywords", :title => "Site Keywords",  :value => "Opal", :setting_type => "Public", :description => "The Keywords Metatag for your site. Used for search engine submission. Seperated by commas.", :item_type => "string")
     Setting.create(:name => "site_description", :title => "Site Description",  :value => "The Free, Open Source, Item Listing Application. List Anything!", :setting_type => "Public", :description => "The description for your site. Used in the title of your page(at the top of your browswer) and for search engine submission.", :item_type => "string")
     #Setting.create(:name => "admin_email", :title => "Admin Email Address",  :value => "admin@example.com", :setting_type => "Public", :description => "The email address of the master admin of this site.", :item_type => "string") # deprecated as of 0.3.5
     Setting.create(:name => "theme", :title => "Theme",  :value => "fracture", :setting_type => "Hidden", :description => "This is the visual theme for the entire system", :item_type => "string")
     Setting.create(:name => "max_items_per_user", :title => "Maximum Items per User",  :value => "0", :setting_type => "Item", :description => "This specifies the maximum number of items a user can create. Set to 0 for unlimited.", :item_type => "string")
     Setting.create(:name => "items_per_page", :title => "Items Per Page",  :value => "10", :setting_type => "Item", :description => "This is the number of items to show per page.", :item_type => "string")
     Setting.create(:name => "item_approval_required", :title => "Approval Required",  :value => "0", :setting_type => "Item", :description => "Enable this if you want to approve items created by users before they can be seen by the public. All unapproved items can viewed in the admin section. If disabled, all items will become approved upon creation.", :item_type => "bool")
     Setting.create(:name => "allow_user_registration",  :title => "User Registration", :value => "1", :setting_type => "User", :description => "This specifies if users can register for a new account.", :item_type => "bool")
     Setting.create(:name => "show_user_login", :title => "Display User Login",  :value => "1", :setting_type => "User", :description => "This specifies if the user login box is visible on the top menu bar. If disabled, users can login at site.example.com/browse/login", :item_type => "bool")
     Setting.create(:name => "users_can_delete_items", :title => "Let Users Delete Their Items",  :value => "1", :setting_type => "Item", :description => "This allows users to delete items that they've created. If disabled, only admins can delete items.", :item_type => "bool")
     Setting.create(:name => "caching", :title => "Page Caching",  :value => "0", :setting_type => "System", :description => "This allows item pages to be cached to speed up performance. A flat file is stored on the server that visitors will see, instead of having the server generate a dynamic page every time.", :item_type => "bool")
     Setting.create(:name => "enable_item_description", :title => "Enable Item Description",  :value => "1", :setting_type => "Item", :description => "Enable/Disable Item Description from item details and lists of items.", :item_type => "bool")
     Setting.create(:name => "enable_item_date", :title => "Enable Item Date",  :value => "1", :setting_type => "Item", :description => "Enable/Disable Item Date from item details and lists of items. This shows the date that the item was created.", :item_type => "bool")
     Setting.create(:name => "enable_contact_us", :title => "Enable Contact Us Form",  :value => "1", :setting_type => "Public", :description => "Enable/Disable The Contact Us Form in the About section.", :item_type => "bool")
     
     # Create Categories
     Category.create(:name => "Uncategorized", :category_id => 0, :description => "Things that are just too cool to fit into one category.")
     Category.create(:name => "Uncategorized Child", :category_id => 1, :description => "Things that are just too cool to fit into one category.")
     Category.create(:name => "Uncategorized GrandChild", :category_id => 2, :description => "Things that are just too cool to fit into one category.")
     
  end 

  def self.down
  end
end
