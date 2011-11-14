# Support class & instance methods for Plugin Classes(Not the Actual Plugin Class) like PluginImage, PluginComment, etc.=
module Opal
  module ActsAsOpalPlugin       
    module ClassMethods              
      def record(record)
        where(:record_id => record.id, :record_type => record.class.name)
      end
            
      def approved
         where("is_approved = ?", "1")
      end

      def newest_first 
         order("created_at DESC")
      end
      
      def oldest_first 
         order("created_at ASC")
      end
            
      def plugin # get plugin record for this class
        Plugin.where("name = ?", system_name).first
      end
      
      def system_name # the plain, system name of the plugin, ie: Image
        name.gsub("Plugin", "")
      end  
      
      def get_setting(name)
        plugin.get_setting(name)
      end
      
      def get_setting_bool(name)
        plugin.get_setting_bool(name)
      end 
      
      def installed? # has this plugin been installed?
        table_exists?
      end
      
      # override ActiveRecord.can?
      def can?(performer, action, options = {})
        options[:record] ||= nil # record is parent 
        
        case performer
        when User        
          case action.to_sym          
          when :create, :new
            GroupPluginPermission.for_plugin_and_group(plugin, performer.group).can?(action) || (options[:record] ? options[:record].is_user_owner?(performer) : false) || super(performer, action, options)
          else
            GroupPluginPermission.for_plugin_and_group(plugin, performer.group).can?(action) || super(performer, action, options)            
          end 
        end 
      end
    end
    
    module InstanceMethods
      # override ActiveRecord#can?
      def can?(performer, action, options = {})
        case performer
        when User
          case action.to_sym          
          when :destroy, :delete, :edit, :update, :view, :read
            (GroupPluginPermission.for_plugin_and_group(self.class.plugin, performer.group).can?(action) || (self.is_user_owner?(performer) && !performer.anonymous?)) || record.can?(performer, action, options) || performer.is_admin?
          when :approve
            is_user_owner?(performer) || super(performer, action, options)
          else
            GroupPluginPermission.for_plugin_and_group(self.class.plugin, performer.group).can?(action) || super(performer, action, options)
          end             
        end                 
      end      
      
      def set_as_item_preview # called after a plugin record/item is created
        if record_type == "Item" && self.class == Setting.get_global_settings[:default_preview_type] # if this plugin is set as the default preview class...
            record.update_attributes(:preview_type => self.class.name, :preview_id => id) if !record.preview? # set self as preview if no preview exists
        end 
      end

      def reset_preview
        if record_type == "Item"         
          if self == record.preview
  	    	  record.update_attributes(:preview_type => nil, :preview_id => nil)  # reset item preview to nil
            preview_successor = Setting.global_settings[:default_preview_type].record(record).first # look for a successor preview 
            #logger.info preview_successor.inspect
            record.update_attributes(:preview_type => preview_successor.class.name, :preview_id => preview_successor.id) if preview_successor # set some other record as item's preview
          end
        end 
      end
      
      def is_approved?
        self.is_approved == "1" if respond_to?(:is_approved) 
      end   

      def send_new_plugin_record_notification
      	record_owner = self.record ? self.record.user : nil
      	if record_owner
      		Emailer.new_plugin_record_notification(self).deliver if record_owner.user_info.notify_of_item_changes && self.user_id != record_owner.id
      	end 
      end  
      
      def set_approval
        if respond_to?(:is_approved) && self.user
          self.is_approved = "1" if !GroupPluginPermission.for_plugin_and_group(self.class.plugin, self.user.group).requires_approval? || record.is_user_owner?(user) || user.is_admin? # approve if not required or owner or admin
        end  
      end    
    end    
  end
end 

module ActiveRecord
  class Base
      def self.acts_as_opal_plugin(options = {}) # for use in plugins
      	# Option Defaults
      	options[:notifications] = true if options[:notifications].nil?

	  	  send(:extend, Opal::ActsAsOpalPlugin::ClassMethods)
	     	send(:include, Opal::ActsAsOpalPlugin::InstanceMethods)		  
        send(:belongs_to, :record, :polymorphic => true)
        send(:before_create, :set_approval)
		    send(:after_create, :set_as_item_preview)
		    send(:before_destroy, :reset_preview)
		    #send(:validates_presence_of, :user_id)		
		    send(:after_create, :send_new_plugin_record_notification) if options[:notifications]       
      end        
  end 
end

