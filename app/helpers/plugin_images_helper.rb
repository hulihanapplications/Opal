module PluginImagesHelper
 def thumbnail(plugin_image, options = {}) # show thumbnail for an image
   options[:preview]     = false if options[:preview].nil? 
   options[:class]       ||= "thumbnail" 
   options[:description] ||= plugin_image.description
   if !plugin_image.nil? # item exists
       if options[:preview]
         link_to(image_tag(plugin_image_url(plugin_image, :thumbnail), options), :rel => "colorbox")
         #return raw "<a href=\"#{h plugin_image.url}\"  title=\"#{h plugin_image.description}\" rel=\"colorbox\"><img src=\"#{plugin_image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h plugin_image.description}\"></a>"
       else
         image_tag(plugin_image_url(plugin_image, :thumbnail), options)
       end     
   else # item doesn't exist
      icon("failure", I18n.t("notice.item_not_found", :item => Item.model_name.human))
   end       
 end
 
 
 def plugin_image_url(plugin_image, mode = :normal) # modes: normal/thumbnail
   URI::join("assets", "item_images", plugin_image.item_id, mode.to_s, plugin_image.filename)
 end
end