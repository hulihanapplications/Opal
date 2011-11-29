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

 
 def feature_icon(feature)
   if !feature.icon_url.nil? && feature.icon_url != "" # Show unique feature icon, but if not set, show default 
    image_tag(feature.icon_url, :class => "icon", :title => feature.name)
   else 
    icon("feature", feature.name)
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
   content_tag(:div, :align => :center, :class => "back") do
     link_to(icon("arrow_left") + " #{I18n.t("single.back")}", options[:url])
   end
 end
  

  
  def loading #show loading box
    theme_image_tag("loading.gif", :class => "loading")
  end  
  

  
  def current_url
    CGI::escape(request.url)
  end
  
  # set record to be used in next request 
  def remember_record(record)
    # display hidden form tags for record information when working with a polymorphic record(which belongs to 'record')
    [hidden_field_tag(:id, record.id), hidden_field_tag(:record_type, record.class.name), hidden_field_tag(:record_id, record.id)].join("\n").html_safe
  end
  
  # link to polymorphic record
  def link_to_record(record)
    link_to record.to_s, record_path(record) if record
  end
  
  def record_header(record)   
    if record.respond_to?(:record)
      case record.record
      when Item
        render :partial => "items/item_header", :locals => {:item => record.record, :options => {:show_item_info => true, :show_item_title => true}}
      end 
    else
      case record
      when Item
        render :partial => "items/item_header", :locals => {:item => record, :options => {:show_item_info => true, :show_item_title => true}}
      end  
    end     
  end
end
