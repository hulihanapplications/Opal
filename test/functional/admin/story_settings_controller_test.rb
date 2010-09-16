require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/story_settings_controller'

# Re-raise errors caught by the controller.
class Admin::StorySettingsController; def rescue_action(e) raise e end; end

class Admin::StorySettingsControllerTest < Test::Unit::TestCase
  fixtures :admin_story_settings

  def setup
    @controller = Admin::StorySettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = story_settings(:first).id
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

    assert_not_nil assigns(:story_settings)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:story_setting)
    assert assigns(:story_setting).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:story_setting)
  end

  def test_create
    num_story_settings = StorySetting.count

    post :create, :story_setting => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_story_settings + 1, StorySetting.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:story_setting)
    assert assigns(:story_setting).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      StorySetting.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      StorySetting.find(@first_id)
    }
  end
end
