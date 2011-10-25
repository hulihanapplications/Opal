module RSpec
  module Core    
    class ExampleGroup      
      # configure request with additional information that would be similar to a browser.
      def configure_request
        request.env["HTTP_REFERER"] = "/"
      end
    end
  end 
end