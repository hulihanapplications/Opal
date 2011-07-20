module RSpec
  module Core    
   class ExampleGroup     
      def bypass_plugin_permissions 
        @controller.stub!(:can_group_create_plugin).and_return(true)
        @controller.stub!(:can_group_update_plugin).and_return(true)
        @controller.stub!(:can_group_delete_plugin).and_return(true)        
      end
    end 
  end 
end