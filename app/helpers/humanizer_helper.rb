module HumanizerHelper
    def included(base)
      asdasd
      #base.send(:include, Humanizer)
    end
    
    self.class.send(:include, Humanizer)
 
    def tesht 
      "testing..."  
    end
    
    def humanizer_question_off
      self.class.send(:include, Humanizer)
      return humanizer_question
    end
    
end