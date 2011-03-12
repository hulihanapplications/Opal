xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel  {
    xml.title("#{@category.name} - #{Item.model_name.human(:count => :other)} - #{[@setting[:title]].join(" - ")}")
    xml.link(url_for(:action => "category", :controller => "items", :id => @category, :only_path => false ))
    xml.description("#{@category.name} - #{Item.model_name.human(:count => :other)} - #{[@setting[:title],  @setting[:description]].join(" - ")}")
    xml.language("#{I18n.locale}")
    xml << render(:partial => "list_items", :locals => {:items => @items})
  }
}
