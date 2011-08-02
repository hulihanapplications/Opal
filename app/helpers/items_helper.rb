module ItemsHelper
  def preview(item) # show preview of item
    preview_record = item.preview
    if preview_record && preview_record.is_approved?
        render :partial => "#{preview_record.class.name.pluralize.underscore}/preview", :locals => {:record => preview_record, :item => item}  rescue nil
    else # no preview found
        content_tag :div, :class => "preview_not_found preview" do 
          link_to content_tag(:h2, I18n.t("notice.item_not_found", :item => I18n.t("single.preview"))), {:action => "view", :controller => "items", :id => item}, :title => item.name
        end       
    end
  end  
end 