require "spec_helper"

describe PluginImage do
  context "validations" do
    describe "cannot_belong_to_self" do
      it "fails if page belongs to itself" do
        parent_page = FactoryGirl.create(:page)
        new_page = Page.find parent_page
        new_page.page = parent_page
        new_page.save.should == false
        new_page.errors.should_not be_nil
      end
    end    
  end
  
  describe "can?" do
    describe :read do
      context "group accessibility" do
        before :each do 
          @user =  FactoryGirl.create(:user)
        end
        
        it "returns false with a user who isn't on the group access list" do 
          restricted_page = FactoryGirl.create(:group_access_only_page)
          restricted_page.can?(@user, :read).should == false
        end
        
        it "returns true with a user who is on the group access list" do 
          restricted_page = FactoryGirl.create(:group_access_only_page, :group_ids => [@user.group_id])
          restricted_page.can?(@user, :read).should == true
        end        
      end
    end 
  end

end