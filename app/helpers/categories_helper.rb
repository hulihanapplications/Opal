module CategoriesHelper
def descend_category(category, options = {})    # recursive print out  category name and other information 
    # initialize default values for options
    options[:include_children] ||= false  # needed to get the item counts for a category
    options[:include_blank]    ||= false  # include a blank option? 
    options[:depth]            ||= 10      # how many levels to descend
    options[:truncate_length]  ||= 30     # Truncate name after this amount of characters
    options[:show_item_count]  ||= false   # show the item count
    options[:make_link]        ||= true   # make the category name a link to the category page
    options[:make_radio_button]||= false  # add an <input type="radio"... button 
    options[:make_checkbox]    ||= false  # add an <input type="checkbox"... button 
    options[:id_to_check]     ||= 0  # if the id to check matches the category id, select the radio button
    options[:id_to_disable]    ||= 0  # diable this id's radio/check button
    options[:id_to_ignore]     ||= 0  # ignore this id   
    options[:input_name]       ||= "item[category_id]"  # name of the html input
    options[:admin_controls] = false if options[:admin_controls].nil?          # show the admin controls (edit/delete)    
   
    if category.id != options[:id_to_ignore]     
      html = "<div class=\"#{options[:class]}\" style=\"#{options[:style]}\"><div class=\"indent\">\n"              
        html += "<table cellpadding=0 cellspacing=0 style=\"width:100%\"><tr>" 
          html += "<td>" + link_to(truncate(category.name, :length => options[:truncate_length]), {:action => "category",  :controller => "items", :id => category}, :class => "category_link", :title => category.description) + "</td>"
          html += "<td align=right>#{category.get_item_count(:include_children => options[:include_children])}</td>"  if options[:show_item_count]

          options[:id_to_check] == category.id ? checked_value = "CHECKED" : checked_value = ""
          options[:id_to_disable] == category.id ? disabled_value = "DISABLED" : disabled_value = ""          
          if options[:make_radio_button] # make a radio button
            options[:id_to_check] == category.id ? checked_value = "CHECKED" : checked_value = "" # check if this radio button should be checked
            options[:id_to_disable] == category.id ? disabled_value = "DISABLED" : disabled_value = "" # check if this radio button should be disabled
            html += "<td align=right><input type=\"radio\" name=\"#{options[:input_name]}\" value=\"#{category.id}\" #{checked_value} #{disabled_value}></td>"
          end
          
          if options[:admin_controls] # show admin controls      
            html += "<td align=right class=\"icon_column\"><img src=\"/themes/#{@setting[:theme]}/images/icons/help.png\" class=\"icon help\" title=\"#{category.description}\"></td>" if category.description && category.description != ""            
            html += "<td align=right class=\"icon_column\">" + link_to(icon("new", "#{t("label.item_new_child", :item => Page.model_name.human)}"), {:action => "new", :controller => "categories", :id => category}, :class => "transparent") + "</td>"              
            html += "<td align=right class=\"icon_column\">" + link_to(icon("edit"), {:action => "edit", :controller => "categories", :id => category}, :class => "transparent") + "</td>"
            html += "<td align=right class=\"icon_column\">" + link_to(icon("delete"), {:action => "delete", :controller => "categories", :id => category}, :confirm => "Are you sure you want to delete this category? All #{Item.model_name.human(:count => :other)} in this category will be also be deleted.", :class => "transparent") + "</td>"
          end   
          
          html += "<td align=right><input type=\"checkbox\" name=\"category_id\" value=\"1\" #{checked_value} #{disabled_value}></td>" if options[:make_checkbox]                  
        html += "</tr></table>\n" 
        html += "<div class=\"spacer\"></div>" if options[:show_spacer]
      
      if options[:depth] > 0 # if we can still descend
        options[:depth] = options[:depth] - 1 # decrement depth counter
        options[:truncate_length] = options[:truncate_length] - 1 # decrement truncate length by x characters
        for child_category in category.child_categories # for each of the children...
           html += descend_category(child_category, options) # call recursive print_category for child.
        end
      end
      html += "</div></div>\n"
      return raw html
    else 
      return "" # return empty string for concatenation
    end
  end 
  
  def category_select_tag(name, value = nil, options = {})   
    options[:id_to_ignore]    ||= nil 
    options[:include_blank]   = false if options[:include_blank].nil?  

    html = String.new
    html += content_tag(:div, content_tag(:table, content_tag(:tr) do ; content_tag(:td, options[:include_blank].is_a?(String) ? options[:include_blank] : I18n.t("single.none"), :align => "left") + content_tag(:td, radio_button_tag(name, "", (value.blank? || value.to_s == "0")), :align => "right") ; end, :style => "width:100%", :cellpadding => "0", :cellspacing => "0"), :class => "indent") + tag(:hr) if options[:include_blank]
     for category in Category.get_parent_categories  
       html += descend_category(category, :input_name => name, :include_children => @setting[:include_child_category_items], :make_radio_button => true, :id_to_check => value, :id_to_ignore => options[:id_to_ignore], :truncate_length => 35)  
   end
   raw html
  end  
end