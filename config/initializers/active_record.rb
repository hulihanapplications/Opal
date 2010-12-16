

module ActiveRecord
  class Base
     def self.combine_conditions(array_of_conditions)
       # designed to take an array of condition set arrays and reform them into a AR-compatible condition array
       # ie: [["name = ?", "bob"], ["(created_at > ? and created_at < ?)", 1.year.ago, 1.year.from_now]]  => ["name = ? and (created_at > ? and created_at < ?)", "bob", 1.year.ago, 1.year.from_now]   
       conditions = Array.new
       values = Array.new
       array_of_conditions.each do |conditions_array|
         conditions << conditions_array[0] # place the condition in an array
         # extract values
         for i in (1..conditions_array.size - 1)
           values << conditions_array[i]
         end 
       end
       [conditions.join(" AND "), values].flatten
     end
  end
end

