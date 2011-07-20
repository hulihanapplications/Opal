require 'spec_helper'

describe PluginController do  
  render_views
  
  describe "as admin" do
    before(:each) do
      login_admin
    end 
  end
  
  context "as user" do
    before(:each) do
      login_user
    end 
        
    pending :vote
    pending :change_approval
  end
end
