class ZeroEightZero < ActiveRecord::Migration
  def change
    add_column :logs, :ip, :string
    add_column :logs, :archived_target, :string    
  end 
  
  def up
    # Migrate Item Logs to Polymorphic Log 
    for log in Log.where("item_id is not ?", nil)
      log.update_attributes(:target_type => "Item", :target_id => log.item_id)
      puts "#{Log.model_name.human} #{log.id} #{I18n.t("single.updated", :default => "Updated")}" 
    end
    
    # Move public images to assets  
    src = Rails.root.join("public", "images")
    dst = Rails.root.join("app", "assets", "images")
    if File.exists?(src)
      for file in Dir[File.join(src, "*")]
        FileUtils.mv(file, dst) # mv public assets to images
        puts file.to_s + " -> " + dst.to_s
      end 
      FileUtils.rmdir(src) # remove directory if empty
    else 
      I18n.t("notice.item_not_found", :item => src)
    end  
  end
    
  def down      
  end
end
