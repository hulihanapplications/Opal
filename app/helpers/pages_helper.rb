module PagesHelper
  def link_to_page(page, options = {})
    options[:url] ||= page_path(page)
    raw link_to(page.title, options[:url], :class => options[:class], :title => page.description.present? ? page.description : page.title)   
  end

  # override default REST helper for page_path
  def page_path(page)
    page.is_public_page? ? page_root_path(page) : url_for(:action => :show, :controller => :pages, :id => page)
  end 

  # Generate special root path for a page
  #   example.com/my-page
  def page_root_path(page)
    "/#{page.to_param}"
  end

  def show_page(page) # prints out page content
    if page && page.content 
      #return raw page.content
      return content_tag(:div, raw(page.content), :class => "page") unless page.content.blank?
    else # either no page found or no content for page.
      return nil
    end
  end

  def nav_link_page(page) 
    navlinks = Array.new # container to hold nav links
      # navlinks <<  (link_to root_page.title, {:action => "page", :controller => "pages", :id => root_page}) +  " &raquo; " + message # home
    unless page.root? # only do this to child pages 
      navlinks <<  link_to_page(page.page.page) if  page.page &&  page.page.page # add grandparent page
      navlinks <<  link_to_page(page.page) if page.page # add parent page
      navlinks <<  link_to_page(page)
    end 
    
    if !navlinks.empty? # if there are any navlinks...
      return raw "<div class=\"navlinks\">" + navlinks.join(" &raquo; ") + "</div>"
    else # no navlinks shown
      return ""
    end
  end 

  def descend_page(page, options = {})    # recursively print out page title and other information
    # initialize default values for options
    options[:depth]             ||= 5      # how many levels to descend
    options[:truncate_length]   ||= 30     # Truncate title after this amount of characters
    options[:make_link]         = true if options[:make_link].nil?  # make the page title a link to the page's actual page
    options[:make_radio_button] = false if options[:make_radio_button].nil? # add an <input type="radio"... button 
    options[:make_checkbox]     = false if options[:make_chekcbox].nil? # add an <input type="checkbox"... button 
    options[:id_to_check]       ||= 0  # if the id to check matches the page id, select the radio button
    options[:id_to_disable]     ||= 0  # diable this id's radio/check button
    options[:id_to_ignore]      ||= 0  # ignore this id        
    options[:input_name]        ||= "page[page_id]"  # name of the html input
    options[:admin_controls]    = false   if options[:admin_controls].nil?          # show the admin controls (edit/delete)    
    options[:class]             ||= ""  # css class
    options[:style]             ||= ""  # css style
      
    if page.id != options[:id_to_ignore] 
      # Set up formatting 
      html = "<div class=\"#{options[:class]}\" style=\"#{options[:style]}\"><div class=\"indent\">\n"              
        html += "<table cellpadding=0 cellspacing=0 style=\"width:100%\"><tr>" 
          html += "<td  align=left>"
            if options[:make_link]
              html += link_to(truncate(page.title, :length => options[:truncate_length]), {:action => "page",  :controller => "pages", :id => page}, :class => "page_link", :title => page.description) 
            else
              html += "#{truncate(page.title, :length => options[:truncate_length])}"              
            end 
          html += "</td>"
          options[:id_to_check] == page.id ? checked_value = "CHECKED" : checked_value = ""
          options[:id_to_disable] == page.id ? disabled_value = "DISABLED" : disabled_value = ""           
          if options[:make_radio_button] # make a radio button        
            html += "<td align=right><input type=\"radio\" name=\"#{options[:input_name]}\" value=\"#{page.id}\" #{checked_value} #{disabled_value}></td>"
          end
          html += "<td align=right>#{friendly_date page.created_at}</td>" if options[:show_date]
         
          if options[:admin_controls] # show admin controls      
            html += "<td align=right class=\"icon_column\"><img src=\"/themes/#{@setting[:theme]}/images/icons/private.png\" class=\"icon help\" title=\"This is not published and cannot be seen by others.\"></td>" if !page.published                        
            html += "<td align=right class=\"icon_column\"><img src=\"/themes/#{@setting[:theme]}/images/icons/help.png\" class=\"icon help\" title=\"#{page.description}\"></td>" if page.description && page.description != ""            
            html += "<td align=right class=\"icon_column\">" + link_to(icon("new", "#{t("label.item_new_child", :item => Page.model_name.human)}"), {:action => "new", :controller => "pages", :id => page}, :class => "transparent") + "</td>" if page.is_public_page?              
            html += "<td align=right class=\"icon_column\">" + link_to(icon("edit"), {:action => "edit", :controller => "pages", :id => page}, :class => "transparent") + "</td>" 
            html += "<td align=right class=\"icon_column\">" + link_to(icon("delete"), {:action => "delete", :controller => "pages", :id => page}, :confirm => "Are you sure you want to delete this?", :class => "transparent") + "</td>" if !page.is_system_page? && page.deletable 
          end  

          html += "<td align=right><input type=\"checkbox\" name=\"page_id\" value=\"1\" #{checked_value} #{disabled_value}></td>" if options[:make_checkbox]
        html += "</tr></table>\n"
        html += "<div class=\"spacer\"></div>" if options[:show_spacer]
      
      if options[:depth] > 0 # if we can still descend
        options[:depth] = options[:depth] - 1 # decrement depth counter
        options[:truncate_length] = options[:truncate_length] - 1 # decrement truncate length by x characters
        for child in page.children # for each of the children...
           html += descend_page(child, options) # call recursive function for child.
        end
      end
      html += "</div></div>\n"
      return raw html
    else 
      return "" # return empty string for concatenation
    end 
  end      
end