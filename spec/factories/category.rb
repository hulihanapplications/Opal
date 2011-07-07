Factory.define :category do |o|
  o.sequence(:name) { |n| "Category #{n}" }  
end