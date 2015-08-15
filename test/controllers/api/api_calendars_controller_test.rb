require 'test_helper'

class ApiCalendarsControllerTest < ActionController::TestCase
  tests Api::V1::ApiCalendarsController

  test "should return unauthorized for missing authentication token" do
    get :leave_days, format: :ics
    assert_response :unauthorized
  end

  test "should return unauthorized for wrong authentication token" do
    get :leave_days, format: :ics, API_AUTH_TOKEN: 'some_wrong_token'
    assert_response :unauthorized
  end

  test "should get leave days with valid token" do
    get :leave_days, format: :ics, API_AUTH_TOKEN: users(:working_api_user_with_pause).token
    assert_response :success
  end

  test "should get public holidays with valid token" do
    get :public_holidays, format: :ics, API_AUTH_TOKEN: users(:working_api_user_with_pause).token
    assert_response :success
  end

end
