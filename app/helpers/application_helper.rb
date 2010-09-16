# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
 def friendly_date(date)
  if date > Time.now.beginning_of_day and date < Time.now.end_of_day # sometime today
   return "Today at "+ date.strftime("%I:%M %p")
  elsif (date < Time.now.beginning_of_day) and (date > Time.now.yesterday.beginning_of_day) # yesterday
   return "Yesterday at "+ date.strftime("%I:%M %p")
  elsif (date < Time.now.yesterday.beginning_of_day) and (date > Time.now.beginning_of_week) # This week, :shows => Monday
   return  "" + date.strftime("%A") + " at " +  date.strftime("%I:%M %p")
  elsif (date > Time.now.beginning_of_year) # Anytime this Year
   return  "" + date.strftime("%b %d") + " at " +  date.strftime("%I:%M %p")
  else # Any Other Time
   return "" + date.strftime("%b %d %Y") + " at " + date.strftime("%I:%M %p")
  end
 end
  
  def get_setting(name) # get a setting from the database
   setting = Setting.find(:first, :conditions => ["name = ?", name], :limit => 1 )
   return setting.value
   rescue # ActiveRecord not found
     return false   
  end
 
  def get_setting_bool(name) # get a setting from the database return true or false depending on "1" or "0"
   setting = Setting.find(:first, :conditions => ["name = ?", name], :limit => 1 )
   if setting.value == "1"
     return true
   else # not true
     return false
   end
   rescue # ActiveRecord not found
     return false   
  end

  def show_page(page) # prints out page content
    if page && page.content 
      return page.content  
    else # either no page found or no content for page.
      return nil
    end
  end
  
  def page_link(page) # prints out the link for a page.
     return link_to("<b>#{page.title}</b>", {:action => "page", :controller => "pages", :id => page}, :title => page.description)
     #return "<a href=\"/about/page/#{page.id}\" title=\"#{page.description}\"><b>#{page.title}</b></a><br>"
  end
 
  def user_avatar(user, options = {:size => "normal"})
    if !user.nil? # user exists    
      if user.use_gravatar? 
        gravatar_image(user.email, :size => options[:size])
      else # don't use gravatar, check local avatars 
        if File.exists?(RAILS_ROOT + "/public/images/avatars/" + user.id.to_s + ".png") 
           return "<img src=\"/images/avatars/#{user.id.to_s}.png\" class=\"avatar_#{options[:size]}\" title=\"#{user.username}\">"
        else # get default avatar
           return "<img src=\"/themes/#{@setting[:theme]}/images/default_avatar.png\" class=\"avatar_#{options[:size]}\" title=\"#{user.username}\">"
        end
      end
    else # user doesn't exist
      return "<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\" title=\"User cannot be found.\">"      
    end     
  end 


  def gravatar_image(email, options = {:size => "normal"})
    return "<img src='http://www.gravatar.com/avatar.php?gravatar_id=#{Digest::MD5.hexdigest(email.downcase)}' class=\"avatar_#{options[:size]}\">"
  end
  
  def nav_link_category(category) # prints out a nav link for an category, ie: Home > General > Test Item
    navlinks = Array.new # container to hold nav links
    navlinks << link_to("#{h category.name}", {:action => "category", :controller => "items", :id => category}, :title => category.description) # Add Category Name
    if category.category_id != 0 # if the item's category is a sub category, print one more category link
        navlinks << link_to("#{h category.category.name}", {:action => "category", :controller => "items", :id => category.category}, :title => category.category.description) 
      if category.category.category_id != 0 # if the item's category is a sub category, print one more category link
        navlinks << link_to("#{h category.category.category.name}", {:action => "category", :controller => "items", :id => category.category.category}, :title => category.category.category.description) 
      else # the item's category is a parent category, print home
        navlinks << (link_to "Home", {:action => "index", :controller => "browse"}) 
      end      
    else # the item's category is a parent category, print home
        navlinks << (link_to "Home", {:action => "index", :controller => "browse"})
    end
    navlinks = navlinks.reverse # reverse items 
    return "<div class=\"navlinks\"><b>" + navlinks.join(" &raquo; ") + "</b></div>"
  end
  
  def nav_link_item(item) # prints out a nav link for an category, ie: Home > General > Test Item
    navlinks = Array.new # container to hold nav links
    navlinks << link_to("#{h item.name}", {:action => "view", :controller => "items", :id => item}, :title => h(item.description)) 
    navlinks << link_to("#{h item.category.name}", {:action => "category", :controller => "items", :id => item.category}, :title => item.category.description) 
    if item.category.category_id != 0 # if the item's category is a sub category, print one more category link
      navlinks << link_to("#{h item.category.category.name}", {:action => "category", :controller => "items", :id => item.category.category}, :title => item.category.category.description)
    else # the item's category is a parent category, print home
      navlinks << (link_to "Home", {:action => "index", :controller => "browse"}) 
    end
    navlinks = navlinks.reverse
    return "<div class=\"navlinks\"><b>" + navlinks.join(" &raquo; ") + "</b></div>"
  end  
  
  def nav_link_page(page) 
    navlinks = Array.new # container to hold nav links
      #root_page = Page.get_system_page("About Home")
      # navlinks <<  (link_to root_page.title, {:action => "page", :controller => "pages", :id => root_page}) +  " &raquo; " + message # home
    if page.page_id != 0 # only do this to child pages 
      navlinks <<  link_to("#{h page.page.page.title}", {:action => "page", :controller => "pages", :id => page.page.page}, :title => page.page.page.description) if  page.page &&  page.page.page # add grandparent page
      navlinks <<  link_to("#{h page.page.title}", {:action => "page", :controller => "pages", :id => page.page}, :title => page.page.description) if page.page # add parent page
      navlinks <<  link_to("#{h page.title}", {:action => "page", :controller => "pages", :id => page}, :title => page.title)
    end 
    
    if navlinks.size > 0 # if there are any navlinks...
      return "<div class=\"navlinks\"><b>" + navlinks.join(" &raquo; ") + "</b></div>"
    else # no navlinks shown
      return ""
    end
  end 
  
  def item_thumbnail(item, options = {})   
      # set defaults
      options[:preview] ||= false 
      options[:class] ||= "thumbnail"
      
      if !item.nil? # item exists
        image = PluginImage.find(:first, :conditions => ["item_id = ? and is_approved = '1'", item.id], :order => "created_at ASC") 
        if image
           if options[:preview]
            return "<a href=\"#{h image.url}\"  title=\"#{h image.description}\" rel=\"colorbox\"><img src=\"#{image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h image.description}\"></a>"
           else
            return "<img src=\"#{image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h image.description}\">"            
           end 
        else                
           return "<img src=\"/themes/#{@setting[:theme]}/images/default_item_image.png\" class=\"#{options[:class]}\">"
        end     
      else # item doesn't exist
        return "<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\" title=\"#{@setting[:item_name]} cannot be found.\">"      
      end 
  end 

 def thumbnail(image, options = {}) # show thumbnail for an image
      options[:preview] ||= false 
      options[:class] ||= "thumbnail" 
      if !image.nil? # item exists
         if options[:preview]
          return "<a href=\"#{h image.url}\"  title=\"#{h image.description}\" rel=\"colorbox\"><img src=\"#{image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h image.description}\"></a>"
         else
          return "<img src=\"#{image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h image.description}\">"            
         end     
      else # item doesn't exist
        return "<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\" title=\"#{@setting[:item_name]} cannot be found.\">"      
      end       
 end
 
 def feature_icon(feature)
     if !feature.icon_url.nil? && feature.icon_url != "" # Show unique feature icon, but if not set, show default 
      return "<img src=\"#{feature.icon_url}\" class=\"icon\" title=\"#{h feature.name}\">"         
     else 
      return "<img src=\"/themes/#{@setting[:theme]}/images/icons/feature.png\" class=\"icon\" title=\"#{h feature.name}\">"       
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
            html += "<td align=right class=\"icon_column\">" + link_to("<img src=\"/themes/#{@setting[:theme]}/images/icons/new.png\" class=\"icon\" title=\"Add new child page to #{page.title}\">", {:action => "new", :controller => "pages", :id => page}, :class => "transparent") + "</td>" if page.is_public_page?              
            html += "<td align=right class=\"icon_column\">" + link_to("<img src=\"/themes/#{@setting[:theme]}/images/icons/edit.png\" class=\"icon\" title=\"Edit\">", {:action => "edit", :controller => "pages", :id => page}, :class => "transparent") + "</td>"
            html += "<td align=right class=\"icon_column\">" + link_to("<img src=\"/themes/#{@setting[:theme]}/images/icons/delete.png\" class=\"icon\" title=\"Delete\">", {:action => "delete", :controller => "pages", :id => page}, :confirm => "Are you sure you want to delete this?", :class => "transparent") + "</td>" if !page.is_system_page? 
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
      return html
    else 
      return "" # return empty string for concatenation
    end 
 end  
 
 def descend_category(category, options = {})    # recursive print out  category name and other information 
    # initialize default values for options
    options[:include_children] ||= false  # needed to get the item counts for a category
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
          html += "<td style=\"\">" + link_to(truncate(category.name, :length => options[:truncate_length]), {:action => "category",  :controller => "items", :id => category}, :class => "category_link", :title => category.description) + "</td>"
          html += "<td align=right><b>#{category.get_item_count(:include_children => options[:include_children])}</b></td>"  if options[:show_item_count]

          options[:id_to_check] == category.id ? checked_value = "CHECKED" : checked_value = ""
          options[:id_to_disable] == category.id ? disabled_value = "DISABLED" : disabled_value = ""          
          if options[:make_radio_button] # make a radio button
            options[:id_to_check] == category.id ? checked_value = "CHECKED" : checked_value = "" # check if this radio button should be checked
            options[:id_to_disable] == category.id ? disabled_value = "DISABLED" : disabled_value = "" # check if this radio button should be disabled
            html += "<td align=right><input type=\"radio\" name=\"#{options[:input_name]}\" value=\"#{category.id}\" #{checked_value} #{disabled_value}></td>"
          end
          
          if options[:admin_controls] # show admin controls      
            html += "<td align=right class=\"icon_column\"><img src=\"/themes/#{@setting[:theme]}/images/icons/help.png\" class=\"icon help\" title=\"#{category.description}\"></td>" if category.description && category.description != ""            
            html += "<td align=right class=\"icon_column\">" + link_to("<img src=\"/themes/#{@setting[:theme]}/images/icons/new.png\" class=\"icon\" title=\"Add new child category to #{category.name}\">", {:action => "new", :controller => "categories", :id => category}, :class => "transparent") + "</td>"              
            html += "<td align=right class=\"icon_column\">" + link_to("<img src=\"/themes/#{@setting[:theme]}/images/icons/edit.png\" class=\"icon\" title=\"Edit\">", {:action => "edit", :controller => "categories", :id => category}, :class => "transparent") + "</td>"
            html += "<td align=right class=\"icon_column\">" + link_to("<img src=\"/themes/#{@setting[:theme]}/images/icons/delete.png\" class=\"icon\" title=\"Delete\">", {:action => "delete", :controller => "categories", :id => category}, :confirm => "Are you sure you want to delete this category? All #{@setting[:item_name_plural]} in this category will be also be deleted.", :class => "transparent") + "</td>"
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
      return html
    else 
      return "" # return empty string for concatenation
    end
  end 

 def icon(name, title = "", css_class = "") # show icon
   return "<img src=\"/themes/#{@setting[:theme]}/images/icons/#{name}.png\" class=\"icon #{css_class}\" title=\"#{title}\">"
 end
 
 def score(options = {}) # print out a score
   options[:type]   ||= "Number" # type of score to show
   options[:min]    ||= 1 # minimum number to create
   options[:max]    ||= 5 # maximum number to create
   options[:value]  ||= 0 # num of stars to fill in  
   
   html = ""
   if options[:type] == "Stars"
     for i in options[:min].to_i..options[:value].to_i # show filled stars
       html << icon("star_selected")
     end
     
     for i in 1..(options[:max].to_i - options[:value].to_i) # show empty stars
       html << icon("star_empty")
     end   
   else
     html += "<span class=\"score\">#{options[:value]}</span> out of #{options[:max]}"
   end 
   return html 
 end
 
 
end
