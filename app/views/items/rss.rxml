xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel  {
    xml.title("#{t("single.new").capitalize} #{Item.model_name.human(:count => :other)} - #{[@setting[:title]].join(" - ")}")
    xml.link(url_for(:controller => "items", :only_path => false ))
    #xml.link "rel" => "self", "href" => url_for(:only_path => false, :controller => 'items', :action => 'rss')
    xml.description("#{t("single.new").capitalize} #{Item.model_name.human(:count => :other)} - #{[@setting[:title],  @setting[:description]].join(" - ")}")
    xml.language("#{I18n.locale}")
    xml << render(:partial => "list_items", :locals => {:items => @latest_items})
  }
}
