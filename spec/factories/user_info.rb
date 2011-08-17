Factory.define :user_info do |o|
  o.association :user, :factory => :user
  o.street_address '123 Fake St.'
  o.city		   'Fakeville'
  o.state		   'FA'
  o.zip 		   '12345'
  o.country		   'Fakia'
  o.use_gravatar   '1'
  o.notify_of_new_messages true 
  o.notify_of_item_changes true
end

