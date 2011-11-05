xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel  {
    xml.title("#{@record.record.to_s} #{PluginDiscussion.model_name.human}: #{@discussion.title} - #{t("label.items_latest", :items => PluginDiscussionPost.model_name.human(:count => :other))} - #{@setting[:title]}")
    xml.link(url_for(:action => "view", :controller => "plugin_discussions", :id => @discussion.id, :only_path => false))
    xml.description("#{@record.record.to_s}: #{@discussion.title} - #{[@setting[:title],  @setting[:description]].join(" - ")}")
    xml.language("#{I18n.locale}")
    for post in @posts
      xml.item do
        xml.title("#{post.user.username}: " + "#{h truncate(post.post, :length => 50)}")
        xml.description("#{h post.post}")
        # rfc822
        xml.pubDate(post.created_at.rfc2822)
      xml.link(record_path(@discussion, :only_path => false))
      xml.guid(record_path(@discussion, :only_path => false))
      end
    end
  }
}
