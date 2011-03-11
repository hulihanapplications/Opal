# Support class & instance methods for Plugins 
module PluginSupport
  module ClassMethods  
    def test
      "self.test"
    end    
    
    def plugin # get plugin record associated with plugin
      return Plugin.find_by_name(self.name.gsub(/Plugin/, ""))
    end   
    
    def get_setting(name)
      self.plugin.get_setting(name)  
    end
    
    def get_setting_bool(name)
      self.plugin.get_setting_bool(name)  
    end    
  end
  
  module InstanceMethods
    def test
      self.class.to_s
    end 
    
    def plugin # get plugin record associated with plugin
      return Plugin.find_by_name(self.class.name.gsub(/Plugin/, ""))
    end 

    def get_setting(name)
      self.plugin.get_setting(name)  
    end
    
    def get_setting_bool(name)
      self.plugin.get_setting_bool(name)  
    end     
  end
end
