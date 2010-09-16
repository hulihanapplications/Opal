require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/story_reviews_controller'

# Re-raise errors caught by the controller.
class Admin::StoryReviewsController; def rescue_action(e) raise e end; end

class Admin::StoryReviewsControllerTest < Test::Unit::TestCase
  fixtures :admin_story_reviews

  def setup
    @controller = Admin::StoryReviewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = story_reviews(:first).id
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

    assert_not_nil assigns(:story_reviews)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:story_review)
    assert assigns(:story_review).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:story_review)
  end

  def test_create
    num_story_reviews = StoryReview.count

    post :create, :story_review => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_story_reviews + 1, StoryReview.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:story_review)
    assert assigns(:story_review).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      StoryReview.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      StoryReview.find(@first_id)
    }
  end
end
