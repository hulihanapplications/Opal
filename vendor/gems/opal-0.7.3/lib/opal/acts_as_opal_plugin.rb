# Support class & instance methods for Plugin Classes(Not the Actual Plugin Class) like PluginImage, PluginComment, etc.=
module Opal
  module ActsAsOpalPlugin       
    module ClassMethods  
      def plugin # get plugin record for this class
        Plugin.where("name = ?", system_name) 
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
    end
    
    module InstanceMethods
      def is_approved?
         self.is_approved == "1" if respond_to?(:is_approved) 
      end   
    end
  end
end 