require File.join(File.dirname(File.expand_path(__FILE__)), "..", "test_helper.rb")

class BrowseControllerTest < ActionController::TestCase
  # Replace this with your real tests.  
  test "should get index" do
    login_admin
    #puts assigns.to_yaml
    get :index
    assert_response :success
    #assert_not_nil assigns(:posts)
  end  
end
 