require 'spec_helper'

describe "Browse" do
  describe "as visitor" do
    it "GET /browse should work" do
      get "/browse"      
      @response.status.should be(200)
    end
  end
end
