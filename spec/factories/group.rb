Factory.define :group do |o|
  o.sequence(:name) { |n| "Group #{n}" }  
end