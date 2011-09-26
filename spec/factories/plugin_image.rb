Factory.define :plugin_image do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  # Upload File By Default
  o.image File.new(Rails.root + 'spec/fixtures/images/rails.png')
  #file.close   
end

Factory.define :plugin_image_remote, :parent => :plugin_image do |o|
  o.image 	nil
  o.remote_image_url "http://localhost/"
end
