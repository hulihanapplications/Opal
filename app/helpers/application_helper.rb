# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
 def friendly_date(date)
  if date > Time.now.beginning_of_day and date < Time.now.end_of_day # sometime today
   return distance_of_time_in_words_to_now(date, :include_seconds => true).capitalize + " " + I18n.t("single.ago").downcase
  elsif (date < Time.now.beginning_of_day) and (date > Time.now.yesterday.beginning_of_day) # yesterday
   return I18n.l(date, :format => :yesterday) 
  elsif (date < Time.now.yesterday.beginning_of_day) and (date > Time.now.beginning_of_week) # This week, :shows => Monday
   return  I18n.l(date, :format => :weekday) 
  elsif (date > Time.now.beginning_of_year) # Anytime this Year
   return I18n.l(date, :format => :short)
  else # Any Other Time
   return I18n.l(date, :format => :long)
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
      #return raw page.content
      return content_tag(:div, raw(page.content), :class => "page") unless page.content.blank?
    else # either no page found or no content for page.
      return nil
    end
  end
  
  def link_to_page(page, options = {})
    options[:truncate_length] = 256 if options[:truncate].nil?    
    url ||= {:action => "page",  :controller => "pages", :id => page}
    raw link_to(truncate(t("page.title.#{page.title.delete(' ').underscore}", :default => page.title), :length => options[:truncate_length]), url, :class => options[:class], :title => t("page.description.#{page.title.delete(' ').underscore}", :default => page.description))   
  end

   def user_avatar(user, options = {:size => "normal"})
    if !user.nil? # user exists    
      if user.use_gravatar? 
        gravatar_image(user, :size => options[:size])
      else # don't use gravatar, check local avatars 
        avatar_image(user, :size => options[:size])
      end
    else # user doesn't exist
      return raw "<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\" title=\"#{t("notice.item_not_found", :item => User.model_name.human)}\">"      
    end     
  end 

  def avatar_image(user, options = {:size => "normal"})
      if File.exists?(Rails.root.to_s + "/public/images/avatars/" + user.id.to_s + ".png") 
         return raw "<img src=\"/images/avatars/#{user.id.to_s}.png\" class=\"avatar_#{options[:size]}\" title=\"#{user.username}\">"
      else # get default avatar
         return raw "<img src=\"/themes/#{@setting[:theme]}/images/default_avatar.png\" class=\"avatar_#{options[:size]}\" title=\"#{user.username}\">"
      end        
  end 
  
  def gravatar_image(object, options = {:size => "normal"})
    email = object.class == User ? object.email.downcase : object.class == String ? object : nil 
    return raw "<img src='http://www.gravatar.com/avatar.php?gravatar_id=#{Digest::MD5.hexdigest(email)}?d=#{URI.escape(@setting[:url] + @setting[:theme_url] + "/images/default_avatar.png")}&s=100' class=\"avatar_#{options[:size]}\" title=\"#{object.class == User ? object.username : nil}\">"
  end


  
  def nav_link_category(category) # prints out a nav link for an category, ie: Home > General > Test Item
    navlinks = Array.new # container to hold nav links
    navlinks << link_to(content_tag(:span, category.name, :itemprop => "title"), {:action => "category", :controller => "items", :id => category}, :title => category.description, :itemprop => "url") # Add Category Name
    if category.category_id != 0 # if the item's category is a sub category, print one more category link
        navlinks << link_to(content_tag(:span, category.category.name, :itemprop => "title"), {:action => "category", :controller => "items", :id => category.category}, :title => category.category.description, :itemprop => "url") 
      if category.category.category_id != 0 # if the item's category is a sub category, print one more category link
        navlinks << link_to(content_tag(:span, category.category.category.name, :itemprop => "title"), {:action => "category", :controller => "items", :id => category.category.category}, :title => category.category.category.description, :itemprop => "url") 
      else # the item's category is a parent category, print home
        navlinks << (link_to  content_tag(:span, (Page.public.with_name("home").first).title, :itemprop => "title"), {:action => "index", :controller => "browse"}, :itemprop => "url") 
      end      
    else # the item's category is a parent category, print home
        navlinks << (link_to  content_tag(:span, (Page.public.with_name("home").first).title, :itemprop => "title"), {:action => "index", :controller => "browse"}, :itemprop => "url")
    end
    navlinks = navlinks.reverse # reverse items 
    return raw "<div class=\"navlinks\">" + navlinks.collect{|navlink| ("<span itemscope item_type=\"http://data-vocabulary.org/Breadcrumb\">#{navlink}</span>")}.join(" &raquo; ") + "</div>"
  end
  
  def nav_link_item(item) # prints out a nav link for an category, ie: Home > General > Test Item
    navlinks = Array.new # container to hold nav links
    navlinks << link_to(content_tag(:span, item.name, :itemprop => "title"), {:action => "view", :controller => "items", :id => item}, :title => h(item.description), :itemprop => "url") 
    navlinks << link_to(content_tag(:span, item.category.name, :itemprop => "title"), {:action => "category", :controller => "items", :id => item.category}, :title => item.category.description, :itemprop => "url") 
    if item.category.category_id != 0 # if the item's category is a sub category, print one more category link
      navlinks << link_to(content_tag(:span, item.category.category.name, :itemprop => "title"), {:action => "category", :controller => "items", :id => item.category.category}, :title => item.category.category.description, :itemprop => "url")
    else # the item's category is a parent category, print home
      navlinks << (link_to content_tag(:span, (Page.public.with_name("home").first).title, :itemprop => "title"), {:action => "index", :controller => "browse"}, :itemprop => "url") 
    end
    navlinks = navlinks.reverse
    return raw "<div class=\"navlinks\">" + navlinks.collect{|navlink| ("<span itemscope item_type=\"http://data-vocabulary.org/Breadcrumb\">#{navlink}</span>")}.join(" &raquo; ") + "</div>"
  end  
  
  def nav_link_page(page) 
    navlinks = Array.new # container to hold nav links
      #root_page = Page.get_system_page("About Home")
      # navlinks <<  (link_to root_page.title, {:action => "page", :controller => "pages", :id => root_page}) +  " &raquo; " + message # home
    if page.page_id != 0 # only do this to child pages 
      navlinks <<  link_to_page(page.page.page) if  page.page &&  page.page.page # add grandparent page
      navlinks <<  link_to_page(page.page) if page.page # add parent page
      navlinks <<  link_to_page(page)
    end 
    
    if navlinks.size > 0 # if there are any navlinks...
      return raw "<div class=\"navlinks\">" + navlinks.join(" &raquo; ") + "</div>"
    else # no navlinks shown
      return ""
    end
  end 
  
 def thumbnail(image, options = {}) # show thumbnail for an image
      options[:preview] = false if options[:preview].nil? 
      options[:class] ||= "thumbnail" 
      if !image.nil? # item exists
         if options[:preview]
          return raw "<a href=\"#{h image.url}\"  title=\"#{h image.description}\" rel=\"colorbox\"><img src=\"#{image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h image.description}\"></a>"
         else
          return raw "<img src=\"#{image.thumb_url}\" class=\"#{options[:class]}\" title=\"#{h image.description}\">"            
         end     
      else # item doesn't exist
        return raw "<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\" title=\"#{Item.model_name.human} cannot be found.\">"      
      end       
 end
 
 def feature_icon(feature)
     if !feature.icon_url.nil? && feature.icon_url != "" # Show unique feature icon, but if not set, show default 
      return raw "<img src=\"#{feature.icon_url}\" class=\"icon\" title=\"#{h feature.name}\">"         
     else 
      return raw "<img src=\"/themes/#{@setting[:theme]}/images/icons/feature.png\" class=\"icon\" title=\"#{h feature.name}\">"       
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

 def icon(name, title = nil, css_class = "") # show icon
   title ||= I18n.t("single.#{name}", :default => name.humanize) # if translation for icon name doesn't exist, use english  
   return raw "<img src=\"/themes/#{@setting[:theme]}/images/icons/#{name}.png\" class=\"icon #{css_class}\" title=\"#{title}\">"
 end
 
 
 
 def score(options = {}) # print out a score
   options[:type]   ||= Setting.global_settings[:plugin_review][:review_type] # type of score to show
   options[:min]    ||= 1 # minimum number to create
   options[:max]    ||= 5 # maximum number to create
   options[:value]  ||= 0 # num of stars to fill in  
   
   html = ""
   if options[:type] == "Stars"
     for i in 1..options[:value].to_i # show filled stars
       html << icon("star_selected", "")
     end
     
     for i in 1..(options[:max].to_i - options[:value].to_i) # show empty stars
       html <<  icon("star_empty", "")
     end   

   else
     html += "<span class=\"score\">#{options[:value]}</span> out of #{options[:max]}"
   end 
   return raw html 
 end
 

  
  def errors_for(someobject) # print out errors for an object
   messages = Array.new  
   if someobject.class == Hash 
       someobject.each do |key, value| 
          messages <<  raw("#{key} #{value}") 
       end     
   else # check for active_record
     if defined?(someobject.errors) && someobject.errors.any?
        someobject.errors.full_messages.each do |msg| 
          messages <<  raw(msg)
       end
     end     
   end 
   if messages.size > 0
    return raw "<div class=\"errorExplanation\"><ul>" + messages.map{|member| "<li>#{member}</li>"}.join("\n") + "</ul></div>"
   else
    return nil
   end 
  end
  
  #alias :error_messages_for :errors_for

  
  def theme_url # get the path to the current theme
    return raw "/themes/#{@setting[:theme]}"
  end
  
  def theme_image_tag(filename, options = {})
    path_array = [theme_url, "images", filename]
    src = path_array.join("/")
    image_tag(src, options)
  end
  
  def star_field_tag(object, method_name, options = {})
    options[:value] ||= 0
    options[:max]   ||= 5
    options[:input_name] ||= "#{object}[#{method_name}]"
    html = String.new

    html << "
    <script type=\"text/javascript\">
      $(function(){
      $('.star_field_#{object.to_s}_#{method_name.to_s}').rating({
          callback: function(value, link){
            //alert(value);
            $(\"##{object.to_s}_#{method_name.to_s}\").val(value); // set input value 
        }
       });
      });
      </script>
    "                                
              
    for i in 1..options[:max]                                       
      html << "<input class=\"star_field_#{object.to_s}_#{method_name.to_s}\" type=\"radio\" name=\"star_field_#{object.to_s}_#{method_name.to_s}\" value=\"#{i}\" #{ "checked=\"checked\"" if i == options[:value].to_i } />\n\n"
    end 
    
    html << "<input name=\"#{options[:input_name]}\" type=\"hidden\" id=\"#{object.to_s}_#{method_name.to_s}\" value=\"#{h(options[:value])}\">"                    
    return raw html
  end
 
  def slider_field_tag(object, method_name, options = {})
    options[:value] ||= 0
    options[:min]   ||= 0
    options[:max]   ||= 5
    options[:input_name] ||= "#{object}[#{method_name}]"
    html = String.new

    html << "<input name=\"#{options[:input_name]}\" type=\"range\" id=\"#{object.to_s}_#{method_name.to_s}_range\" min=\"#{options[:min]}\" max=\"#{options[:max]}\"  value=\"#{h(options[:value])}\">"                
    
    html << "
        <script type=\"text/javascript\">
          $(document).ready(function() {
            $(\"##{object.to_s}_#{method_name.to_s}_range\").rangeinput();
          });
        </script>
    "                                                
    return raw html    
  end   

  
  def tags_field_tag(object, method_name, options = {})
    html = String.new
    class_name = object.class.to_s.underscore
    options[:input_name] ||= "#{class_name}[#{method_name.to_s}]"    
    if object.class == Item
      html << "<input name=\"#{options[:input_name]}\" type=\"text\" id=\"#{class_name}_#{method_name.to_s}\" value=\"#{h(object.tags)}\">"                
    end
    return raw html
  end

  def tags_links(someobject)
    tags = Array.new
    if someobject.class == Item
      for tag in someobject.plugin_tags
         tags << link_to_tag(tag)
      end 
    end
    return raw "#{icon("tag")} #{PluginTag.model_name.human(:count => :other)}: #{tags.join(", ")}" unless tags.size == 0 
  end
  
  def link_to_tag(tag)
    raw link_to(h(tag.name), {:action => "tag", :controller => "items", :tag => CGI::escape(h tag.name)}) 
  end
  
  def using_tiny_mce?
    defined?(@uses_tiny_mce) && @uses_tiny_mce
  end
  
 # make a list of items sortable
 #  list_id: the ul with li's to sort
 #  update_url: the url to send the list item ids to(in order)
 #  update_id: The dom object to send update to
 def sortable_list(list_id, update_url, update_id)  
   html = <<-HTML
      <script type="text/javascript">
          $(function(){
              $("##{list_id}").sortable({
                  //placeholder: "placeholder",              
                  stop: function(event, ui){
                      $("##{update_id}").html('#{theme_image_tag("loading.gif", :class => "loading")}') // show loading
                      //alert("New position: " + ui.item.index());
                      update_order();
                  }
              });
              
              $("##{list_id}").disableSelection();
              
              function update_order() // update
              {
                  //alert("Order Changed!")
                  var ids = $('##{list_id}').sortable('toArray'); // get element ids in order
                  //alert(ids)
                  $.post('#{update_url}', {
                      ids: ids 
                  }, function(data){
                     //alert("#{update_id}")

                     //alert("Data Loaded: " + data);
                     $("#"+"#{update_id}").html(data)
                  });
              } 
              
              // Handle AJAX Errors 
              $("##{update_id}").ajaxError(function(event, request, settings){
                  //alert("There was an ajaxError!")
                  //$("#"+update_id).html(settings.url)  
                  $("#"+"#{update_id}").html('<div class="notice"><div class="failure">#{I18n.t("activerecord.errors.template.body")}<br />'+ settings.url +'</div></div>')                               
              });       
         });        
      </script>
   HTML
   return raw html
 end  
 
 def back(options = {})
   options[:url] ||= :back
   raw "<div align=center class=\"back\">" + link_to(icon("arrow_left") + " #{I18n.t("single.back")}", options[:url]) + "</div>"
 end
 
  def log_icon(log)
    case log.log_type
    when "download"
       icon("file", t("single.downloaded"), "icon help")
    when "create"
       icon("new", t("single.created"), "icon help")
    when "new"
       icon("new", t("single.created"), "icon help")
    when "update"
      icon("edit", t("single.updated"), "icon help")
    when "delete"
      icon("delete", t("single.deleted"), "icon help")
    when "system"
      icon("success", t("single.system") + " " + Log.model_name.human)
    when "warning"
      icon("warning", t("single.warning"), "icon help")
    else
      icon("unknown", t("single.unknown"), "icon help")
    end  
  end 
  
  def link_to_user(user, options = {})
    options[:avatar] = false if options[:avatar].nil?
    options[:name] = true if options[:name].nil?
    options[:avatar_class] ||= "tiny"
    link_to raw((options[:name] ? user.to_s : "") + " " + (options[:avatar] ? user_avatar(user, :size => options[:avatar_class]) : "")), user_path(user)
  end
  
  def loading #show loading box
    theme_image_tag("loading.gif", :class => "loading")
  end  
  
  def category_select_tag(name, value = nil, options = {})   
    options[:id_to_ignore]    ||= nil 
    options[:include_blank]   = false if options[:include_blank].nil?  

    html = String.new
    html += content_tag(:div, content_tag(:table, content_tag(:tr) do ; content_tag(:td, options[:include_blank].is_a?(String) ? options[:include_blank] : I18n.t("single.none"), :align => "left") + content_tag(:td, radio_button_tag(name, nil, (value.blank? || value.to_s == "0")), :align => "right") ; end, :style => "width:100%", :cellpadding => "0", :cellspacing => "0"), :class => "indent") + tag(:hr) if options[:include_blank]
     for category in Category.get_parent_categories  
       html += descend_category(category, :input_name => name, :include_children => @setting[:include_child_category_items], :make_radio_button => true, :id_to_check => value, :id_to_ignore => options[:id_to_ignore], :truncate_length => 35)  
   end
   raw html
  end
  
  def current_url
    CGI::escape(request.url)
  end
end

