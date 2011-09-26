class ConvertImagesAndPageCommentsToPlugins < ActiveRecord::Migration
  def up
    # Convert Images to PluginImages and Comments to PluginComments
    for image in Image.all
      p = PluginImage.new
      p.image = File.open(image.path)
      if p.save
        say("#{Image.model_name.human} #{image.id} #{I18n.t("single.updated", :default => "Updated")}", true)
        image.destroy
      end 
    end
    
    for comment in PageComment.all
      p = PluginComment.new(comment.attributes)
      p.record = comment.page
      if p.save
        say("#{PageComment.model_name.human} #{comment.id} #{I18n.t("single.updated", :default => "Updated")}", true)
        comment.destroy
      end      
    end
  end

  def down
    # Revert Recordless PluginImages and page-based PluginComments back to old models 
    for image in PluginImage.where(:record_type => nil, :record_id => nil).all
      i = Image.new      
      if i.save # save to get id
        i.original_filename = image.filename
        FileUtils.cp(image.image.path, i.store_dir)  
        FileUtils.cp(image.image.thumb.path, i.thumb_store_dir)                      
        if i.save # save again
          say("#{PluginImage.model_name.human} #{image.id} #{I18n.t("single.updated", :default => "Updated")}", true)
          image.destroy
        end 
      end 
    end
    
    for comment in PluginComment.where(:record_type => "Page").all
      c = PluginComment.new(comment.attributes)
      c.page_id = comment.record_id
      if c.save
        say("#{PageComment.model_name.human} #{comment.id} #{I18n.t("single.updated", :default => "Updated")}", true)
        comment.destroy
      end      
    end    
  end
end
