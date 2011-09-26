Factory.define :plugin_file do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.title         "Test Title"
  o.downloads     0
  file = File.new(Rails.root + 'spec/fixtures/images/rails.png')
  o.file ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file.path))  
end