require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/email_verifications_controller'

# Re-raise errors caught by the controller.
class Admin::EmailVerificationsController; def rescue_action(e) raise e end; end

class Admin::EmailVerificationsControllerTest < Test::Unit::TestCase
  fixtures :admin_email_verifications

  def setup
    @controller = Admin::EmailVerificationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = email_verifications(:first).id
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

    assert_not_nil assigns(:email_verifications)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:email_verification)
    assert assigns(:email_verification).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:email_verification)
  end

  def test_create
    num_email_verifications = EmailVerification.count

    post :create, :email_verification => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_email_verifications + 1, EmailVerification.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:email_verification)
    assert assigns(:email_verification).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      EmailVerification.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      EmailVerification.find(@first_id)
    }
  end
end
