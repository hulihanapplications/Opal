Factory.define :plugin_file do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.title         "Test Title"
  o.filename      "testfilename.txt"
  o.downloads     0
end