module FlashHelper
  def render_flash(flash)
     if !flash.empty? 
       html = String.new       
       %w{notice success warning failure info}.each do |type|  
         html << content_tag(:div, raw(render_flash_content(flash[type.to_sym])), :class => type) if !flash[type.to_sym].blank? 
       end       
       return raw content_tag(:div, raw(html), :class => "notice")  
     end     
  end
  
  def render_flash_content(object)
    if object.is_a? Array
      return object.collect{|o| content_tag :div, o}.join("\n")
    else 
      return object
    end
  end  
end


