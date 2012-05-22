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
  

 
 def feature_icon(feature)
   if !feature.icon_url.nil? && feature.icon_url != "" # Show unique feature icon, but if not set, show default 
    image_tag(feature.icon_url, :class => "icon", :title => feature.name)
   else 
    icon("feature", feature.name)
   end    
 end 

  def icon(name, title = nil, css_class = "") # show icon
    title ||= I18n.t("single.#{name}", :default => name.to_s.humanize) # if translation for icon name doesn't exist, use english  
    content_tag(:span, "", :class => "icons-#{name} icon #{css_class}", :title => title)
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
                      $("##{update_id}").html('#{loading}') 
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
    content_tag(:div, theme_image_tag("loading.gif", :class => "loading"), :class => :loading)
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

  # Setup the layout, load menus, etc.
  def initialize_layout
    render :partial => "admin/menu" if @show_admin_menu
    render :partial => "user/menu" if @show_user_menu
  end 
end
