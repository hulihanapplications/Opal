require "spec_helper"

describe PluginImage do
  context "carrierwave" do
    it "creates an image properly" do
      @plugin_image = PluginImage.new(Factory.attributes_for(:plugin_image))
      @plugin_image.image = File.open(Rails.root.join("spec/fixtures/images/example.png"))
      @plugin_image.save.should == true      
    end
  end
end