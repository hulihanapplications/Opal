# Support class & instance methods for Plugins 
module PluginSupport
  module ClassMethods  
    def test
      "self.test"
    end    
    
    def plugin # get plugin record associated with plugin
      return Plugin.find_by_name(self.to_s.gsub(/Plugin/, ""))
    end    
  end
  
  module InstanceMethods
    def test
      self.class.to_s
    end 
    
    def plugin # get plugin record associated with plugin
      return Plugin.find_by_name(self.class.to_s.gsub(/Plugin/, ""))
    end     
  end

end
