xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel  {
    xml.title(@title)
    xml.link(blog_path)
    xml.description(@setting[:meta_description].join(" "))
    xml.language("#{I18n.locale}")
    for page in @pages
      xml.item do      
        xml.title(page.title)
        xml.description(truncate(h(page.content),:length => 100))
        # rfc822
        xml.pubDate(page.created_at.rfc2822)
        
        xml.link(page_path(page))
      end
    end
  }
}
