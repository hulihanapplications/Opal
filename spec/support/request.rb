module RSpec
  module Core    
    class ExampleGroup      
      # configure request with additional information that would be similar to a browser.
      def configure_request
        request.env["HTTP_REFERER"] = "/" # reqeust.host_with_port
      end
    end
  end 
end