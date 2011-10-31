xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel  {
    xml.title("#{Page.find_by_name("blog").title} - #{@setting[:title]}")
    xml.link(url_for(:controller => "blog", :only_path => false))
    xml.description(@setting[:meta_description].join(" "))
    xml.language("#{I18n.locale}")
    for page in @pages
      xml.item do      
        xml.title(h page.title)
        xml.description(truncate(h(page.content),:length => 100))
        # rfc822
        xml.pubDate(page.created_at.rfc2822)
        
        xml.link(url_for(:controller => "pages", :action => "page", :id => page, :only_path => false))
        xml.guid(url_for(:controller => "pages", :action => "page", :id => page, :only_path => false))
      end
    end
  }
}
