# Support class & instance methods for Plugin Classes(Not the Actual Plugin Class) like PluginImage, PluginComment, etc.=
module Opal
  module ActsAsOpalPlugin       
    module ClassMethods              
      def item(item)
        where("item_id = ?", item.id)
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
    end
    
    module InstanceMethods
      def set_as_item_preview # called after a plugin record/item is created
        if self.class == Setting.get_global_settings[:default_preview_type] # if this plugin is set as the default preview class...
            item.update_attributes(:preview_type => self.class.name, :preview_id => id) if !item.preview? # set self as preview if no preview exists
        end 
      end

      def reset_preview         
        if self == item.preview
	    	item.update_attributes(:preview_type => nil, :preview_id => nil)  # reset item preview to nil
			preview_successor = Setting.global_settings[:default_preview_type].item(item).first # look for a successor preview 
			logger.info preview_successor.inspect
	    	item.update_attributes(:preview_type => preview_successor.class.name, :preview_id => preview_successor.id) if preview_successor # set some other record as item's preview
	    end 
      end
      
      def is_approved?
         self.is_approved == "1" if respond_to?(:is_approved) 
      end   

      def send_new_plugin_record_notification
      	item_owner = self.item ? self.item.user : nil
      	if item_owner
      		Emailer.deliver_new_plugin_record_notification(self) if item_owner.user_info.notify_of_item_changes && self.user_id != item_owner.id
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
		send(:after_create, :set_as_item_preview)
		send(:before_destroy, :reset_preview)
		#send(:validates_presence_of, :user_id)		
		send(:after_create, :send_new_plugin_record_notification) if options[:notifications]       
      end        
  end 
end

