require 'test_helper'

class StatisticsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get index" do
    given_authenticated_user(users(:admin_user))
    get :index
    assert_response :success
  end

  test "should get working_hours" do
    given_authenticated_user(users(:admin_user))
    get :working_hours
    assert_response :success
  end

  test "should get leave_days" do
    given_authenticated_user(users(:admin_user))
    get :leave_days, date: Date.parse("2015/12/31")
    assert_response :success
    assert_not_nil assigns(:user_leave_days_statistic)
    assert_equal 418, assigns(:total_leave_days)
  end

  test "user should not be allowed to get index" do
    given_authenticated_user(users(:user))
    get :index
    assert_response :redirect
  end

  test "user should not be allowed to get working_hours" do
    given_authenticated_user(users(:user))
    get :working_hours
    assert_response :redirect
  end

  test "user should not be allowed to get leave_days" do
    given_authenticated_user(users(:user))
    get :leave_days
    assert_response :redirect
  end

end
