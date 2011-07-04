module ItemsHelper
  def preview(item) # show preview of item
    preview_record = item.preview
    if preview_record 
        render :partial => "#{preview_record.class.name.pluralize.underscore}/preview", :locals => {:record => preview_record, :item => item}  rescue nil
    else # no preview found
        link_to theme_image_tag("default_item_image.png", :class => "thumbnail"), {:action => "view", :controller => "items", :id => item}, :title => item.name      
    end
  end  
end 