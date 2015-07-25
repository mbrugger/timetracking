require 'test_helper'

class StatisticsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get working_hours" do
    get :working_hours
    assert_response :success
  end

  test "should get leave_days" do
    get :leave_days
    assert_response :success
  end

end
