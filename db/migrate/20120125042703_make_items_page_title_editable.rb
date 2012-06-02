class MakeItemsPageTitleEditable < ActiveRecord::Migration
  class Page < ActiveRecord::Base; end
  def up
    items_page = Page.find_by_name("items")
    if !items_page.nil?
      items_page.update_attribute(:title_editable, true)
    end
  end

  def down
    items_page = Page.find_by_name("items")
    if !items_page.nil?
      items_page.update_attribute(:title_editable, false)
    end
  end
end
