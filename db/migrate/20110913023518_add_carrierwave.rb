class AddCarrierwave < ActiveRecord::Migration
  def up
    # PluginImages
    add_column :plugin_images, :image, :string   
    PluginImage.reset_column_information
    
    # Switch PluginImages to CarrierWave  
    begin  
      for item in Item.all
        item_image_dir = Rails.root.join("public", "item_images", item.id.to_s)
        for plugin_image in item.plugin_images
          unless plugin_image.url.blank?
            orig_image_path = File.join(item_image_dir, "normal", File.basename(plugin_image.url))
            if File.exists?(orig_image_path)
              plugin_image.image = File.open(orig_image_path)
              if plugin_image.save
                say(orig_image_path + "\t->\t" + plugin_image.image.path, true)  
              end           
            end
          end
        end      
        FileUtils.rm_rf(item_image_dir) if File.exists?(item_image_dir)
      end
    rescue => e
      say e.message
      say e.backtrace.join("\n")      
    end 
     
    remove_column :plugin_images, :url
    remove_column :plugin_images, :thumb_url     
     
    # PluginFiles  
    add_column :plugin_files, :file, :string
    PluginFile.reset_column_information    

    # Switch PluginFiles to CarrierWave  
    begin  
      for item in PluginFile.all
        item_files_dir = Rails.root.join("file", "item_files", item.id.to_s)
        for plugin_file in item.plugin_files
          unless plugin_file.filename.blank?          
            file = File.join(item_files_dir, File.basename(plugin_file.filename))
            if File.exists?(file)
              plugin_file.file = File.open(file)
              if plugin_file.save
                say(file + "\t->\t" + plugin_file.file.path, true)  
              end           
            end
          end 
        end      
        FileUtils.rm_rf(item_files_dir) if File.exists?(item_files_dir)
      end
    rescue => e
      say e.message
      say e.backtrace.join("\n")      
    end 
    remove_column :plugin_files, :size
    
    
    # User avatars
    add_column :users, :avatar, :string     

    begin  
      for user in User.all
        avatar_path = Rails.root.join("public", "avatars", user.id.to_s + ".png")
        if File.exists?(avatar_path)
          user.avatar = File.open(avatar_path)
          if user.save
            say(avatar_path + "\t->\t" + user.avatar.path, true)
          end      
          FileUtils.rm(avatar_path)                
        end     
      end
    rescue => e
      say e.message
      say e.backtrace.join("\n")
    end 
    
    User.reset_column_information    
  end   
  
  def down
    remove_column :plugin_images, :image 
    remove_column :users, :avatar     
    remove_column :plugin_files, :file   
    
    add_column :plugin_images, :url, :string
    add_column :plugin_images, :thumb_url, :string
    add_column :plugin_files, :size, :string            
  end  
end
