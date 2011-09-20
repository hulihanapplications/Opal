Factory.define :plugin_image do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  # Upload File By Default
  file = File.new(Rails.root + 'spec/fixtures/images/rails.png')
  o.image ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file.path))
  #file.close   
end

Factory.define :plugin_image_remote, :parent => :plugin_image do |o|
  o.image 	nil
  o.remote_image_url "http://localhost/"
end
