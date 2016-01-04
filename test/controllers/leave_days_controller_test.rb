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

  test "summary should correctly calculate leave days at working year start if days have been consumed" do
    given_authenticated_user(users(:employment_user))
    get :index, user_id: users(:employment_user).id, year: 2014
    assert_response :success
    assert_equal 25, assigns(:leave_days_working_year_start)
    assert_equal 2, assigns(:leave_days_consumed)
    assert_equal 23, assigns(:leave_days_available)
  end

  test "should get new" do
     given_authenticated_user(users(:employment_user))
     get :new, user_id: users(:employment_user).id
     assert_response :success
   end

  test "should create leave_day" do
    @user = users(:employment_user)
    given_authenticated_user(@user)

    new_leave_day = LeaveDay.new
    new_leave_day.date = Date.new
    new_leave_day.leave_day_type = "leave_day"
    new_leave_day.description = "new"

    assert_difference('LeaveDay.count') do
      post :create, user_id: @user.id, leave_day_dates: new_leave_day.date, leave_day: { leave_day_type: new_leave_day.leave_day_type, description: new_leave_day.description }
    end
    assert_redirected_to user_leave_days_path(@user)
    new_leave_day.id = LeaveDay.where(user_id: @user.id).last.id
    assert_leave_day new_leave_day
  end

  test "should get edit" do
    given_authenticated_user(users(:employment_user))
    get :edit, user_id:users(:employment_user).id ,id: users(:employment_user).leave_days.first
    assert_response :success
  end

  test "should update leave_day" do
    @user = users(:employment_user)
    given_authenticated_user(@user)
    changed_leave_day = @user.leave_days.first
    changed_leave_day.description = "updated"
    changed_leave_day.leave_day_type = "absent_day"
    changed_leave_day.date = Date.new

    patch :update, user_id: @user.id, id: @user.leave_days.first.id, leave_day: {date: changed_leave_day.date, leave_day_type: changed_leave_day.leave_day_type, description: changed_leave_day.description}
    assert_redirected_to user_leave_days_path(@user)
    assert_leave_day changed_leave_day
  end

  test "should destroy leave_day" do
    @user = users(:employment_user)
    given_authenticated_user(@user)

    @leave_day = @user.leave_days.first
    assert_difference('LeaveDay.count', -1) do
      delete :destroy, user_id: @user.id, id: @leave_day.id
    end
    assert_redirected_to user_leave_days_path(@user)
  end
end
