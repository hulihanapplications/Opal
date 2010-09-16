require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/user_notifications_controller'

# Re-raise errors caught by the controller.
class Admin::UserNotificationsController; def rescue_action(e) raise e end; end

class Admin::UserNotificationsControllerTest < Test::Unit::TestCase
  fixtures :admin_user_notifications

  def setup
    @controller = Admin::UserNotificationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = user_notifications(:first).id
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

    assert_not_nil assigns(:user_notifications)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user_notification)
    assert assigns(:user_notification).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user_notification)
  end

  def test_create
    num_user_notifications = UserNotification.count

    post :create, :user_notification => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_user_notifications + 1, UserNotification.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user_notification)
    assert assigns(:user_notification).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      UserNotification.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      UserNotification.find(@first_id)
    }
  end
end
