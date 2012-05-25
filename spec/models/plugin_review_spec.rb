require "spec_helper"

describe PluginReview do
  describe "save" do
    it "fails when a users tries to create a second review" do
      record = FactoryGirl.create(:item )
      user = FactoryGirl.create(:user)
      first_review = FactoryGirl.create(:plugin_review, :user => user, :record => record)
      second_review = Factory.build(:plugin_review, :user => user, :record => record)
      second_review.save.should == false
      second_review.errors.size.should_not == 0      
    end
  end
end