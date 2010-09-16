require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/story_statistics_controller'

# Re-raise errors caught by the controller.
class Admin::StoryStatisticsController; def rescue_action(e) raise e end; end

class Admin::StoryStatisticsControllerTest < Test::Unit::TestCase
  fixtures :admin_story_statistics

  def setup
    @controller = Admin::StoryStatisticsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = story_statistics(:first).id
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

    assert_not_nil assigns(:story_statistics)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:story_statistic)
    assert assigns(:story_statistic).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:story_statistic)
  end

  def test_create
    num_story_statistics = StoryStatistic.count

    post :create, :story_statistic => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_story_statistics + 1, StoryStatistic.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:story_statistic)
    assert assigns(:story_statistic).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      StoryStatistic.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      StoryStatistic.find(@first_id)
    }
  end
end
