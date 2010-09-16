require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/tags_controller'

# Re-raise errors caught by the controller.
class Admin::TagsController; def rescue_action(e) raise e end; end

class Admin::TagsControllerTest < Test::Unit::TestCase
  fixtures :admin_tags

  def setup
    @controller = Admin::TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = tags(:first).id
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

    assert_not_nil assigns(:tags)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:tag)
    assert assigns(:tag).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:tag)
  end

  def test_create
    num_tags = Tag.count

    post :create, :tag => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_tags + 1, Tag.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:tag)
    assert assigns(:tag).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Tag.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Tag.find(@first_id)
    }
  end
end
