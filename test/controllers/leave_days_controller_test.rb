require 'test_helper'

class LeaveDaysControllerTest < ActionController::TestCase
  setup do
    @leave_day = leave_days(:one)
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
