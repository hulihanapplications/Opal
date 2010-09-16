require File.dirname(__FILE__) + '/../../test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_user
    assert_difference('Admin::User.count') do
      post :create, :user => { }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_show_user
    get :show, :id => admin_users(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => admin_users(:one).id
    assert_response :success
  end

  def test_should_update_user
    put :update, :id => admin_users(:one).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_destroy_user
    assert_difference('Admin::User.count', -1) do
      delete :destroy, :id => admin_users(:one).id
    end

    assert_redirected_to admin_users_path
  end
end
