class AddCarrierwave < ActiveRecord::Migration
  def up
    # PluginImages
    add_column :plugin_images, :image, :string   
    PluginImage.reset_column_information
 
    # PluginFiles  
    add_column :plugin_files, :file, :string
    PluginFile.reset_column_information    
        
    for item in Item.all
      # Update PluginImages
      item_image_dir = Rails.root.join("public", "images", "item_images", item.id.to_s)
      for plugin_image in item.plugin_images
        unless plugin_image.url.blank?
          orig_image_path = File.join(item_image_dir, "normal", File.basename(plugin_image.url))
          if File.exists?(orig_image_path)
            plugin_image.image = File.open(orig_image_path)
            say(orig_image_path + "\t->\t" + plugin_image.image.path, true) if plugin_image.save              
          end
        end
      end      
      FileUtils.rm_rf(item_image_dir) if File.exists?(item_image_dir)
      # Update PluginFiles
      item_files_dir = Rails.root.join("file", "item_files", item.id.to_s)
      for plugin_file in item.plugin_files
        unless plugin_file.filename.blank?          
          file = File.join(item_files_dir, File.basename(plugin_file.filename))
          if File.exists?(file)
            plugin_file.file = File.open(file)
            say(file + "\t->\t" + plugin_file.file.path, true) if plugin_file.save  
          end
        end 
      end      
      FileUtils.rm_rf(item_files_dir) if File.exists?(item_files_dir)        
    end

     
    remove_column :plugin_images, :url
    remove_column :plugin_images, :thumb_url     
    remove_column :plugin_files, :size
    
    # User avatars
    add_column :users, :avatar, :string     
    User.reset_column_information    
    #begin  
      for user in User.all
        avatar_path = Rails.root.join("public", "images", "avatars", user.id.to_s + ".png")
        if File.exists?(avatar_path)
          user.avatar = File.open(avatar_path)
          say(avatar_path + "\t->\t" + user.avatar.path, true) if user.save
          FileUtils.rm(avatar_path)                
        end     
      end
    #rescue => e
    #  say e.message
    #  say e.backtrace.join("\n")
    #end 
    
  end   
  
  def down  
    for user in User.all
      if !user.avatar.blank?
        dst = Rails.root.join("public", "images", "avatars", user.id + ".png")
        if FileUtils.cp(user.avatar.path, dst)
          user.avatar = File.open(avatar_path)
          say(user.avatar.path + "\t->\t" + dst, true)
          user.remove_avatar!
        end       
      end     
    end       
 
    add_column :plugin_files, :size, :string             
    add_column :plugin_images, :url, :string
    add_column :plugin_images, :thumb_url, :string
    PluginImage.reset_column_information  
    PluginFile.reset_column_information
        
    # Copy CarrierWave Files back to the old format
    for user in User.all
      if !user.avatar.blank?
        dst = Rails.root.join("public", "images", "avatars", user.id.to_s + ".png")
          say(user.avatar.path + "\t->\t" + dst, true) if File.exists?(user.avatar.path) && FileUtils.cp(user.avatar.path, dst)
          user.remove_avatar!
      end     
    end    
   
    remove_column :users, :avatar     

    for item in Item.all
      # Move Images to Legacy Format
      for plugin_image in item.plugin_images
        if !plugin_image.image.blank?
          dst = Rails.root.join("public", "images", "item_images", item.id.to_s, "normal", File.basename(plugin_image.image.path))
          thumb_dst = Rails.root.join("public", "images", "item_images", item.id.to_s, "thumbnails", File.basename(plugin_image.image.path))
          FileUtils.mkdir_p(File.dirname(dst)) unless File.exists?(File.dirname(dst))
          FileUtils.mkdir_p(File.dirname(thumb_dst)) unless File.exists?(File.dirname(thumb_dst))                                                          
          say(plugin_image.image.path + "\t->\t" + dst, true) if File.exists?(plugin_image.image.path) && FileUtils.cp(plugin_image.image.path, dst)             
          unless plugin_image.image.thumb.blank?
            say(plugin_image.image.thumb.path + "\t->\t" + thumb_dst, true) if File.exists?(plugin_image.image.thumb.path) && FileUtils.cp(plugin_image.image.thumb.path, thumb_dst)
          end                        
          plugin_image.remove_image!
        end  
      end      
      # Move Files to Legacy Format
      for plugin_file in item.plugin_files
        if !plugin_file.file.blank?
          dst = Rails.root.join("files", "item_files", item.id.to_s, File.basename(plugin_file.file.path))
          FileUtils.mkdir_p(File.dirname(dst)) unless File.exists?(File.dirname(dst))
          say(plugin_file.file.path + "\t->\t" + dst, true) if File.exists?(plugin_file.file.path) && FileUtils.cp(plugin_file.file.path, dst)                              
          plugin_file.remove_file!
        end  
      end        
    end

    remove_column :plugin_images, :image 
    remove_column :plugin_files, :file     

    # Delete CarrierWave dirs     
    public_uploads_path = Rails.root.join("public", "uploads") 
    FileUtils.rm_rf(public_uploads_path) if File.exists?(public_uploads_path)
    private_uploads_path = Rails.root.join("uploads")
    FileUtils.rm_rf(private_uploads_path) if File.exists?(private_uploads_path)      
  end  
end
