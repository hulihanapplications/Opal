Factory.define :plugin_image do |o|
  o.association   :item, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.url           "/path/to/image"
  # Upload File By Default
  file = File.new(Rails.root + 'spec/fixtures/images/rails.png')
  o.local_file ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file.path))
  file.close   
end

Factory.define :plugin_image_remote, :parent => :plugin_image do |o|
  o.local_file 	nil
  o.remote_file "http://localhost/"
end
