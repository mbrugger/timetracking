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
    assert_redirected_to locale_root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "user should be able to browse own leave days" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:user).id
    assert_response :success
  end

  test "summary for migrated user in first year should show migrated days" do
    given_authenticated_user(users(:employment_user_migrated))
    get :index, user_id: users(:employment_user_migrated).id, year: 2014
    assert_response :success
    assert_not_nil assigns(:leave_days)
    assert_equal 30, assigns(:leave_days_working_year_start)
    assert_equal 0, assigns(:leave_days_consumed)
    assert_equal 30, assigns(:leave_days_available)
  end

  test "summary before employment tracked in current system should display error" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:user).id, year: 2012
    assert_response :success
    # assert_nil assigns(:leave_days)
    assert_nil assigns(:leave_days_available)
  end

  test "summary for migrated employment should display error" do
    given_authenticated_user(users(:employment_user_migrated))
    get :index, user_id: users(:employment_user_migrated).id, year: 2013
    assert_response :success
    # assert_nil assigns(:leave_days)
    assert_nil assigns(:leave_days_available)
  end

  test "summary for user in first year should show 25 available days" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:user).id, year: 2015
    assert_response :success
    assert_equal 25, assigns(:leave_days_working_year_start)
    assert_equal 0, assigns(:leave_days_consumed)
    assert_equal 25, assigns(:leave_days_available)
  end

  test "summary for user without employment should show error" do
    given_authenticated_user(users(:unemployed_user))
    get :index, user_id: users(:unemployed_user).id, year: 2015
    assert_response :redirect
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
