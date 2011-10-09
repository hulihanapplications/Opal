module Opal
  module ActionController
    module Base
      def log(attributes = {}) # log something
        log = Log.new(attributes)
        log.user_id = @logged_in_user.id if log.user_id.blank? && !@logged_in_user.anonymous? 
        log.ip = request.env["REMOTE_ADDR"]
        #log.archived_target = attributes[:target] if attributes[:target]
        log.save
      end         
    end
  end
end

