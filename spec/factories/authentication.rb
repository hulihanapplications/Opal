Factory.define :authentication do |o|
  o.association   :user, :factory => :user
  o.uid "12345"
  o.provider "test_provider"
end