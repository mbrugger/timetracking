require 'test_helper'

class LeaveDaysControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "admin should be able to browse other users leave days" do
    given_authenticated_user(users(:admin_user))
    get :index, user_id: users(:other_user)
    assert_response :success
    assert_not_nil assigns(:leave_days)
  end

  test "user should not be able to browse other users leave days" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:other_user).id
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "user should be able to browse own leave days" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:user).id
    assert_response :success
  end


  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:leave_days)
  # end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #
  # test "should create leave_day" do
  #   assert_difference('LeaveDay.count') do
  #     post :create, leave_day: {  }
  #   end
  #
  #   assert_redirected_to leave_day_path(assigns(:leave_day))
  # end
  #
  # test "should show leave_day" do
  #   get :show, id: @leave_day
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @leave_day
  #   assert_response :success
  # end
  #
  # test "should update leave_day" do
  #   patch :update, id: @leave_day, leave_day: {  }
  #   assert_redirected_to leave_day_path(assigns(:leave_day))
  # end
  #
  # test "should destroy leave_day" do
  #   assert_difference('LeaveDay.count', -1) do
  #     delete :destroy, id: @leave_day
  #   end
  #
  #   assert_redirected_to leave_days_path
  # end
end
