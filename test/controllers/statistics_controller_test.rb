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
    get :working_hours, start_date: "1/12/2014", end_date: "31/12/2014"
    assert_response :success
    assert_not_nil assigns(:user_working_hours_statistic)
    assert_equal 943.hours, assigns(:total_working_hours_planned)
    assert_equal 19.hours+29.minutes, assigns(:total_working_hours_actual)
  end

  test "should get working_hours filtered for single user" do
    given_authenticated_user(users(:admin_user))
    get :working_hours, start_date: "1/08/2014", end_date: "31/08/2014", users: [users(:tester).id]
    assert_response :success
    assert_not_nil assigns(:user_working_hours_statistic)
    assert_equal 138.hours+36.minutes, assigns(:total_working_hours_planned)
    assert_equal 24.hours, assigns(:total_working_hours_actual)
  end

  test "should get leave_days" do
    given_authenticated_user(users(:admin_user))
    get :leave_days, date: Date.parse("2015/12/31")
    assert_response :success
    assert_not_nil assigns(:user_leave_days_statistic)
    assert_equal 465, assigns(:total_leave_days)
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
