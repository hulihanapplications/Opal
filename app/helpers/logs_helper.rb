module LogsHelper
    def log_message(log)
    message = String.new
    if log.log # static log message?
      message = log.log
    else # no static log saved, generate message
      if !log.target_type.blank? && !log.target_id.blank? # make sure there's a target class and id
        if log.target # does target actually  
          if log.target_type == "Item"
            message = I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :target => link_to_record(log.target))        
          elsif log.target_type == "PluginComment"    
            message = I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to(truncate(log.target.comment, :length => 40), {:action => "view", :controller => "items", :anchor => log.klass.model_name.human(:count => :other)}))
          elsif log.target_type == "PluginImage"    
            message = plugin_image_thumbnail(log.target, :class => "medium", :preview => true, :style => "float:left;margin-right:5px;")
            message += raw(I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to_record(log.target.record)))
          elsif log.target_type == "PluginReview"    
            message = I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to(log.target.record.name, {:action => "show", :controller => "plugin_reviews", :id => log.target.record_id, :review_id => log.target_id}))
          elsif log.target_type == "PluginDiscussionPost"
            message = I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.plugin_discussion.item), :discussion => link_to(log.target.plugin_discussion.title, {:action => "view", :controller => "plugin_discussions", :id => log.target.plugin_discussion.item, :discussion => log.target.plugin_discussion}), :target => link_to(truncate(log.target.post, :length => 20), {:action => "view", :controller => "plugin_discussions", :id => log.target.plugin_discussion.item.id, :discussion_id => log.target.plugin_discussion, :anchor => log.target_id}))
          elsif log.target_type == "PluginDiscussion"
            message = I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to(log.target.title, {:action => "view", :controller => "plugin_discussions", :id => log.target.record_id, :discussion_id => log.target}))          
          elsif log.target_type == "Page"
            message = I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target.user), :item => log.klass.model_name.downcase, :target => link_to(log.target.title, {:action => "page", :controller => "pages", :id => log.target}))
          elsif log.target_type == "PluginVideo" || log.target_type == "PluginGuide"
            message = I18n.t("log.item_#{log.log_type}_by_user", :user => link_to_user(log.user), :item => log.klass.model_name.human, :name => link_to(log.target, {:action => "view", :controller => "items", :id => log.target, :anchor => log.klass.model_name.human(:count => :other)}))
          elsif log.target_type == "User"
            message = I18n.t("log.models.#{log.target_type.underscore}.#{log.log_type}", :user => link_to_user(log.target), :title => Setting.global_settings[:title])
          else # some other class
            if log.user_id.blank?
              message = I18n.t("log.item_#{log.log_type}", :item => log.klass.model_name.human, :name => log.target.to_s)
            else # user set
              message = I18n.t("log.item_#{log.log_type}_by_user", :user => link_to_user(log.target), :item => log.klass.model_name.human, :name => log.target.to_s)
            end 
          end
        else # target is no where to be found
          message = I18n.t("log.item_#{log.log_type}", :item => "#{I18n.t("single.unknown")} #{log.klass.model_name.human}", :name => log.target_id)
        end  
      end 
    end
    
    return raw message
  end
end