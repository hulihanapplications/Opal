require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper.rb"))

class AdminControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  setup :login_as_admin
  
  test "should get index when logged in as admin" do
    get :index
    assert_response :success
    #assert_not_nil assigns(:posts)
  end  
end
 

