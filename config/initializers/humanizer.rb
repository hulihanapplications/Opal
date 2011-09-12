module Humanizer
  module ActionController
    def self.included(base)
      base.send(:include, ::Humanizer) # add Humanizer support to Controller class
      base.send(:include, InstanceMethods)  
    end
    
    module InstanceMethods
      def check_humanizer_answer
        unless human?
          flash[:failure] = I18n.translate("humanizer.validation.error")
          redirect_to :back
        end
      end
      
      def human?
        if params[:humanizer_answer] && params[:humanizer_question_id]
          self.humanizer_answer = params[:humanizer_answer]
          self.humanizer_question_id = params[:humanizer_question_id]
          return humanizer_correct_answer?                        
        else
          return false
        end 
      end
    end
  end
end

ActionController::Base.send :include, Humanizer::ActionController # add humanizer support to controller
