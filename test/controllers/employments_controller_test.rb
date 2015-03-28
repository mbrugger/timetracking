require 'test_helper'

class EmploymentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "admin should be able to browse other users employments" do
    given_authenticated_user(users(:admin_user))
    get :index, user_id: users(:other_user)
    assert_response :success
    assert_not_nil assigns(:employments)
  end

  test "user should not be able to browse other users employments" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:other_user).id
    assert_redirected_to locale_root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "user should be able to browse own employments" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:user).id
    assert_response :success
  end

  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #
  # test "should create employment" do
  #   assert_difference('Employment.count') do
  #     post :create, employment: {  }
  #   end
  #
  #   assert_redirected_to employment_path(assigns(:employment))
  # end
  #
  # test "should show employment" do
  #   get :show, id: @employment
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @employment
  #   assert_response :success
  # end
  #
  # test "should update employment" do
  #   patch :update, id: @employment, employment: {  }
  #   assert_redirected_to employment_path(assigns(:employment))
  # end
  #
  # test "should destroy employment" do
  #   assert_difference('Employment.count', -1) do
  #     delete :destroy, id: @employment
  #   end
  #
  #   assert_redirected_to employments_path
  # end
end
