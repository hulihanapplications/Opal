require "spec_helper"

describe PluginImage do
  context "validations" do
    describe "cannot_belong_to_self" do
      it "fails if page belongs to itself" do
        parent_page = Factory(:page)
        new_page = Page.find parent_page
        new_page.page = parent_page
        new_page.save.should == false
        new_page.errors.should_not be_nil
      end
    end    
  end
end