# This file creates required data for new installations. 
I18n.locale = ENV['LOCALE'].nil? ? "en" : ENV['LOCALE']  # Define locale 

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
pages[:items].title_editable = true
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

# Create Default Admin Account
@admin = User.new(:first_name => I18n.t('seeds.user.admin.first_name'), :last_name => I18n.t('seeds.user.admin.last_name'), :username => I18n.t('seeds.user.admin.username'), :password => I18n.t('seeds.user.admin.password'), :password_confirmation => I18n.t('seeds.user.admin.password'), :is_admin => "1", :email => I18n.t('seeds.user.admin.email'))
@admin.group_id = Group.admin.id
@admin.is_admin = "1" 
@admin.is_verified = "1"     
@admin.locale = I18n.locale.to_s
@admin.save

# Create Categories
Category.create(:name => I18n.t('seeds.category.uncategorized.name'), :category_id => 0, :description => I18n.t('seeds.category.uncategorized.description'))    

puts "\n" + I18n.t("notice.item_install_success", :item => I18n.t("name")) + "\n"
puts I18n.t("label.login_as", :username => I18n.t('seeds.user.admin.username'), :password => I18n.t('seeds.user.admin.password'))
Log.create(:log => I18n.t("notice.item_install_success", :item => I18n.t("name")), :log_type => "system") # Log Install