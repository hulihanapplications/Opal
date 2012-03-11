class SetSystemPageNames < ActiveRecord::Migration
  def system_page_names 
    %w{category_column banner_top banner_bottom website_top website_bottom email_footer home_page_sidebar new_item category_column}
  end
  
  def up
  	for name in system_page_names
  	  page = Page.find_by_title(I18n.t(:title, :scope => [:seeds, :page, name.to_sym]))
      page.update_attributes(:name => name, :title => nil) if page 
  	end 
  end

  def down
  	for name in system_page_names
      page = Page.find_by_name(name)
      page.update_attributes(:name => nil, :title => I18n.t(:title, :scope => [:seeds, :page, name.to_sym])) if page
  	end
  end
end
