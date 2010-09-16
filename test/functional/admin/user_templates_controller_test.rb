require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/user_templates_controller'

# Re-raise errors caught by the controller.
class Admin::UserTemplatesController; def rescue_action(e) raise e end; end

class Admin::UserTemplatesControllerTest < Test::Unit::TestCase
  fixtures :admin_user_templates

  def setup
    @controller = Admin::UserTemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = user_templates(:first).id
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

    assert_not_nil assigns(:user_templates)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user_template)
    assert assigns(:user_template).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user_template)
  end

  def test_create
    num_user_templates = UserTemplate.count

    post :create, :user_template => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_user_templates + 1, UserTemplate.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user_template)
    assert assigns(:user_template).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      UserTemplate.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      UserTemplate.find(@first_id)
    }
  end
end
