class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.column :name, :string
      t.column :setting_type, :string
      t.column :value, :string
      t.column :item_type, :string
      t.column :options, :string, :default => nil
    end
    
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
  end

  def self.down
    # Delete Fracture Main Logo if it exists
    file = File.join(Rails.root.to_s, "public", "themes", "fracture", "images", "logo.png")
    if File.exists?(file)
      File.delete(file) 
      puts "\tDeleted: #{file}"
    end
    
    drop_table :settings
  end
end
 