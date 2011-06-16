module Opal
  module ActiveRecord
    module Base
      module InstanceMethods
        # assign order number, used in sorting
        def assign_order_number 
          self.order_number = self.class.next_order_number
        end         
      end
      
      module ClassMethods
        # Get the next order number in line for sorting
        def next_order_number
          last_record = self.find(:last, :order => "order_number ASC")
          last_record ? order_number = last_record.order_number + 1 : order_number = 0
          return order_number         
        end        
        
        def test
          "Testing..."
        end   
    
        def acts_as_opal_plugin(options = {}) # for use in plugins
          self.send :include, Opal::ActsAsOpalPlugin::InstanceMethods
          self.send :extend, Opal::ActsAsOpalPlugin::ClassMethods
        end        
      end
    end 
  end
end