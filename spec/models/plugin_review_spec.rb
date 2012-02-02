require "spec_helper"

describe PluginReview do
  desribe "save" do
    it "fails when a users tries to create a second review" do
      record = Factory(:item) 
      user = Factory(:user)
      first_review = Factory(:plugin_review, :user => user, :record => record)
      second_review = Factory.build(:plugin_review, :user => user, :record => record)
      second_review.save.should == false
      second_review.errors.size.should_not == 0      
    end
  end
end