# Pages are used for non-item content.
class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :page_id, :default => 0 # parent page id
      t.integer :user_id, :default => nil # user who added page
      t.column :name, :string, :default => nil
      t.string :title, :default => "" # title of the page
      t.string :description, :default => ""      
      t.string :page_type, :default => "public" # public, system(title & description non-editable)
      t.text :content 
      t.column :deletable, :boolean, :default => true # if page can be deleted    
      t.column :title_editable, :boolean, :default => true # if title can be edited
      t.column :description_editable, :boolean, :default => true # if description can be edited    
      t.column :content_editable, :boolean, :default => true # if content can be edited      
      t.column :published, :boolean, :default => true   
      t.column :locked, :boolean, :default => false 
      t.column :order_number, :integer      
      t.column :display_in_menu, :boolean, :default => true # display in menu    
      t.column :redirect, :boolean, :default => false # redirect this page?  
      t.column :redirect_url, :string, :default => nil # if they want to redirect this to another url
      t.timestamps
    end

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
  end

  def self.down
    drop_table :pages
  end
end
