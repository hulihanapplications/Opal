Factory.define :plugin_video do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"  
  o.title         "Test Video"
  o.description   "This is a test description"
  o.code          '<div style="text-align: center;"><iframe width="560" height="349" src="http://www.youtube.com/embed/4kIKynSUbJw" frameborder="0" allowfullscreen></iframe></div>' 
end
