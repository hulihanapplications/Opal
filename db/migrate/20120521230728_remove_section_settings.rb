class RemoveSectionSettings < ActiveRecord::Migration
  def up
    Setting.find_by_name("section_items").destroy
    Setting.find_by_name("section_blog").destroy      
  end

  def down
    Setting.create(:name => "section_items", :value => "1", :setting_type => "Section", :item_type => "bool")
    Setting.create(:name => "section_blog", :value => "1", :setting_type => "Section", :item_type => "bool")    
  end
end
