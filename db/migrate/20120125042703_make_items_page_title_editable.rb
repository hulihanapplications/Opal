class MakeItemsPageTitleEditable < ActiveRecord::Migration
  def up
    Page.find_by_name("items").update_attribute(:title_editable, true)
  end

  def down
    Page.find_by_name("items").update_attribute(:title_editable, false)
  end
end
