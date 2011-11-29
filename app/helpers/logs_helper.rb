module LogsHelper
    def log_message(log)
    message = String.new
    if log.log # static log message?
      message << log.log
    else # no static log saved, generate message
      if !log.target_type.blank? && !log.target_id.blank? # make sure there's a target class and id
        if log.target # does target actually exist? 
          default_target_message = I18n.t("item_#{log.log_type.normalize_action}".to_sym, :scope => [:log], :item => log.klass.model_name.human.downcase, :name => log.target.to_s)      
          case log.target_type
          when "Item"
            options = {:user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :target => link_to_record(log.target)}
          when "PluginComment"    
            options = {:user => (log.target.user ? link_to_user(log.target.user) : I18n.t("single.anonymous")), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to(truncate(log.target.comment, :length => 40), {:action => "view", :controller => log.target.class.controller_name, :anchor => log.klass.model_name.human(:count => :other)})}
          when "PluginImage"    
            message << raw(plugin_image_thumbnail(log.target, :class => "medium", :preview => true))
            options = {:user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to_record(log.target.record)}
          when "PluginReview"    
            options = {:user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to(log.target.record.name, {:action => "show", :controller => "plugin_reviews", :record_id => log.target_id, :record_type => log.target_type})}
          when "PluginDiscussionPost"
            options = {:user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.plugin_discussion.record), :discussion => link_to(log.target.plugin_discussion.title, {:action => "view", :controller => "plugin_discussions", :record_id => log.target.plugin_discussion, :record_type => log.target.plugin_discussion.class.name}), :target => link_to(truncate(log.target.post, :length => 20), {:action => "view", :controller => "plugin_discussions", :record_type => log.target.plugin_discussion.class.name, :record_id => log.target.plugin_discussion, :anchor => log.target_id})}
          when "PluginDiscussion"
            options = {:user => link_to_user(log.target.user), :item => log.klass.model_name.human.downcase, :parent => link_to_record(log.target.record), :target => link_to(log.target.title, {:action => "view", :controller => "plugin_discussions", :record_id => log.target_id, :record_type => log.target_type})}          
          when "Page"
            options = {:user => link_to_user(log.target.user), :item => log.klass.model_name.downcase, :target => link_to(log.target.title, {:action => "page", :controller => "pages", :id => log.target})}
          when "PluginVideo"
            message = {:user => link_to_user(log.user), :item => log.klass.model_name.human, :name => link_to(log.target, {:action => "view", :controller => log.target.class.controller_name, :id => log.target, :anchor => log.klass.model_name.human(:count => :other)})}
          when "User"
            options = {:user => link_to_user(log.target), :title => Setting.global_settings[:title]}
          else # some other class
            options = {:user => log.user_id.blank? ? I18n.t("single.unknown") : link_to_user(log.target), :item => log.klass.model_name.human, :name => log.target.to_s}
          end                    
          message << I18n.t(log.log_type.normalize_action.to_sym, options.merge(:scope => [:log, :models, log.target.class.name.underscore.to_sym], :default => default_target_message))
        else # target is no where to be found
          message << I18n.t("item_#{log.log_type.normalize_action}".to_sym, :scope => [:log], :item => log.klass.model_name.human, :name => log.target_id)      
        end  
      end  
    end
    
    return raw message
  end
  
 
  def log_icon(log)
    case log.log_type
    when "download"
       icon("file", t("single.downloaded"), "icon help")
    when "create", "new"
       icon("new", t("single.created"), "icon help")
    when "update", "save"
      icon("edit", t("single.updated"), "icon help")
    when "delete", "destroy"
      icon("delete", t("single.deleted"), "icon help")
    when "system"
      icon("success", t("single.system") + " " + Log.model_name.human, "icon help")
    when "warning"
      icon("warning", t("single.warning"), "icon help")
    else
      icon("unknown", t("single.unknown"), "icon help")
    end  
  end   
end