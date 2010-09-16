require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/story_ratings_controller'

# Re-raise errors caught by the controller.
class Admin::StoryRatingsController; def rescue_action(e) raise e end; end

class Admin::StoryRatingsControllerTest < Test::Unit::TestCase
  fixtures :admin_story_ratings

  def setup
    @controller = Admin::StoryRatingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = story_ratings(:first).id
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

    assert_not_nil assigns(:story_ratings)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:story_rating)
    assert assigns(:story_rating).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:story_rating)
  end

  def test_create
    num_story_ratings = StoryRating.count

    post :create, :story_rating => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_story_ratings + 1, StoryRating.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:story_rating)
    assert assigns(:story_rating).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      StoryRating.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      StoryRating.find(@first_id)
    }
  end
end
