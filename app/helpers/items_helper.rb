module ItemsHelper
  def preview(item, options = {}) # show preview of item
    options[:size] ||= "normal" 
    
    preview_record = item.preview
    if preview_record && preview_record.is_approved?
        render :partial => "#{preview_record.class.name.pluralize.underscore}/preview", :locals => {:record => preview_record, :item => item, :options => options }  rescue nil
    else # no preview found
        content_tag :div, :class => "preview_not_found preview" do 
          link_to content_tag(:h2, I18n.t("notice.item_not_found", :item => I18n.t("single.preview"))), {:action => "view", :controller => "items", :id => item}, :title => item.name
        end       
    end
  end 
  
  def item_thumbnail(item, options = {})   
      # set defaults
      options[:preview] = false if options[:preview].nil? 
      options[:class] ||= "thumbnail"
      
      if !item.nil? # item exists
        if item.preview_type == PluginImage.name
           thumbnail(item.preview, options)
        elsif  item.preview_type == PluginVideo.name
           theme_image_tag("preview_video.png", :class => options[:class])
        else # some other preview type
           theme_image_tag("preview.png", :class => options[:class])
        end     
      else # item doesn't exist
        return raw "<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\" title=\"#{Item.model_name.human} cannot be found.\">"      
      end 
  end    
end 