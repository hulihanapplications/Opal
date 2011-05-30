module ActionView
  module Helpers
    module FormOptionsHelper
      def category_select(object, method)
        grouped_collection_select(object, method, Category.parent, :categories, :name, :id, :name)        
      end
    end
  end
end