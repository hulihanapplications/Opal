module ItemsHelper
  def preview(item) # show preview of item
    preview_record = item.preview
    if preview_record
      if preview_record.class == PluginImage
        link_to thumbnail(preview_record,  :preview => true), {:action => "view", :controller => "items", :id => item, :anchor => Plugin.plugins[:image].model_name.human(:count => :other)}, :title => item.name
      elsif preview_record.class == PluginVideo
        # Store Video Content in Colorbox
        html = <<-HTML
          <script>
            $(document).ready(function(){
                $("#preview_link_#{item.id}").colorbox({width:"50%", inline:true, href:"#preview_content_#{item.id}"});              
            });
          </script>
        HTML
        html << link_to(theme_image_tag("preview_video.png", :class => "thumbnail"), "#", :id => "preview_link_#{item.id}")
        html << content_tag(:div, content_tag(:div, preview_record.code.html_safe, :id => "preview_content_#{item.id}"), :style => "display:none")        
        return html.html_safe
      else # some other class      
      end
    else # no preview found
        link_to theme_image_tag("default_item_image.png", :class => "thumbnail"), {:action => "view", :controller => "items", :id => item}, :title => item.name      
    end
  end
  
 
end 