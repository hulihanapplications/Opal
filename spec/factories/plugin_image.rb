Factory.define :plugin_image do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  # Upload File By Default
  file = Rails.root.join('spec/fixtures/images/rails.png')
  #include ActionDispatch::TestProcess
  #uploaded_file = Rack::Test::UploadedFile.new(file, "image/png")
  #uploaded_file = fixture_file_upload(file, "image/png")  
  o.image File.new(file)
  #o.effects {:monochrome => "0", :sepia => "0"}
end

Factory.define :plugin_image_remote, :parent => :plugin_image do |o|
  o.image 	nil
  o.remote_image_url "http://localhost/"
end
