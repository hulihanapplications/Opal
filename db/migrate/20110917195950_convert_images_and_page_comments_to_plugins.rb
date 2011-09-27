class ConvertImagesAndPageCommentsToPlugins < ActiveRecord::Migration
  # Convert Images to PluginImages and Comments to PluginComments
  def up
    for image in Image.all
      plugin_image = PluginImage.new
      if File.exists?(image.path)
        plugin_image.image = File.open(image.path)
        if plugin_image.save
          convert_msg("#{Image.model_name} #{image.id}", "#{PluginImage.model_name} #{plugin_image.id}")
          image.destroy
        end 
      end 
    end
    
    for page_comment in PageComment.all
      plugin_comment = PluginComment.new(:comment => page_comment.comment, :anonymous_name => page_comment.anonymous_name, :anonymous_email => page_comment.anonymous_email)
      plugin_comment.record = page_comment.page      
      plugin_comment.user = page_comment.user
      if plugin_comment.save
        convert_msg("#{PageComment.model_name} #{page_comment.id}", "#{PluginComment.model_name} #{plugin_comment.id}")        
        page_comment.destroy
      end      
    end
  end

  # Revert Recordless PluginImages and page-based PluginComments back to old models 
  def down
    for plugin_image in PluginImage.where(:record_type => nil, :record_id => nil).all
      image = Image.new      
      if image.save # save to get id
        if !plugin_image.image.blank?
          image.original_filename = plugin_image.filename
          cp(plugin_image.image.path, image.store_dir)
          cp(plugin_image.image.thumb.path, image.thumb_store_dir)
          if image.save
            convert_msg("#{PluginImage.model_name} #{plugin_image.id}", "#{Image.model_name} #{image.id}")
            plugin_image.destroy            
          end
        end 
      end
    end
    
    for plugin_comment in PluginComment.where(:record_type => "Page").all
      page_comment = PageComment.new(:comment => plugin_comment.comment, :anonymous_name => plugin_comment.anonymous_name, :anonymous_email => plugin_comment.anonymous_email)
      page_comment.page_id = plugin_comment.record_id
      page_comment.user = plugin_comment.user
      if page_comment.save
        convert_msg("#{PluginComment.model_name} #{plugin_comment.id}", "#{PageComment.model_name} #{page_comment.id}")
        plugin_comment.destroy
      end      
    end    
  end  
end
