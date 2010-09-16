require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/user_settings_controller'

# Re-raise errors caught by the controller.
class Admin::UserSettingsController; def rescue_action(e) raise e end; end

class Admin::UserSettingsControllerTest < Test::Unit::TestCase
  fixtures :admin_user_settings

  def setup
    @controller = Admin::UserSettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = user_settings(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:user_settings)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user_setting)
    assert assigns(:user_setting).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user_setting)
  end

  def test_create
    num_user_settings = UserSetting.count

    post :create, :user_setting => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_user_settings + 1, UserSetting.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user_setting)
    assert assigns(:user_setting).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      UserSetting.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      UserSetting.find(@first_id)
    }
  end
end
