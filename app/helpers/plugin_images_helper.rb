module PluginImagesHelper
  def plugin_image_thumbnail(plugin_image, options = {}) # show thumbnail for an image
    options[:preview]     = false if options[:preview].nil? 
    options[:class]       ||= "preview" 
    options[:title]       ||= plugin_image.description.blank? ? plugin_image.image.filename : plugin_image.description
    if !plugin_image.nil? # item exists
       if options[:preview]
         link_to(image_tag(plugin_image.image.thumb.url, options), plugin_image.image.url, :rel => "colorbox")
         #return raw "<a href=\"#{h plugin_image.url}\"  title=\"#{h plugin_image.description}\" rel=\"colorbox\"><img src=\"#{plugin_image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h plugin_image.description}\"></a>"
       else
         image_tag(plugin_image.image.thumb.url, options)
       end     
    else # item doesn't exist
      icon("failure", I18n.t("notice.item_not_found", :item => Item.model_name.human))
    end       
  end
end