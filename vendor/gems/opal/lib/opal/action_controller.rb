module Opal
  module ActionController
    module Base
      def log(attributes = {}) # log something
        log = Log.new(attributes)
        log.user_id = @logged_in_user.id if log.user_id.blank?
        log.ip = request.env["REMOTE_ADDR"]
        #log.archived_target = attributes[:target] if attributes[:target]
        log.save
      end      
      
      def meta_title(some_object) # create title string for use in HTML head title element    
        title_array = Array.new 
        
        if some_object.class == Item 
          title_array << some_object.name
          title_array << some_object.description if some_object.description && !some_object.description.empty?
          title_array << some_object.category.name + " " + Item.model_name.human(:count => :other)
          title_array << @setting[:meta_title]     
        end
        return title_array.join(" - ")
      end      
    end
  end
end

