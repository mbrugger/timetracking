require 'test_helper'

class ApiStatusControllerTest < ActionController::TestCase
  tests Api::V1::ApiStatusController

  def given_authentication(user)
    @request.env['HTTP_X_API_AUTH_TOKEN'] = user.token
  end

  test "should return unauthorized for missing authentication token" do
    get :status
    assert_response :unauthorized
  end

  test "should return unauthorized for wrong authentication token" do
    @request.env['HTTP_X_API_AUTH_TOKEN'] = 'some_wrong_token'
    get :status
    assert_response :unauthorized
  end

  # curl -v --header "X-API-AUTH-TOKEN: e413t4Kxz7ysXyxY3w9F" http://localhost:3000/api/v1/status
  test "should get status for currently working employee" do
    given_authentication(users(:working_api_user_with_pause))
    get :status
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "running", body["status"]
    assert_equal "0:20", body["duration"]
    assert_equal "0:10", body["pause_duration"]
  end

  test "should get status for currently not working employee" do
    given_authentication(users(:api_user))
    get :status
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal body["status"], "stopped"
  end

  #curl -v -d "" --header "X-API-AUTH-TOKEN: e413t4Kxz7ysXyxY3w9F" http://localhost:3000/api/v1/status/start
  test "should start time entry for currently not working employee" do
    user = users(:api_user)
    given_authentication(user)
    post :start
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "running", body["status"]
    assert_equal 1, user.time_entries.length
  end

  #curl -v -d "" --header "X-API-AUTH-TOKEN: e413t4Kxz7ysXyxY3w9F" http://localhost:3000/api/v1/status/stop
  test "should stop time entry for currently working employee" do
    user = users(:working_api_user)
    given_authentication(user)
    post :stop
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "stopped", body["status"]
    assert_equal 1, user.time_entries.length
    assert !user.time_entries.first.stopTime.nil?, "expected stopTime to be set correctly"
  end

  test "should not return error for stop time entry for currently not working employee" do
    user = users(:api_user)
    given_authentication(user)
    post :stop
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "stopped", body["status"]
    assert_equal 0, user.time_entries.length
  end

  test "should not return error for start time entry for currently working employee" do
    user = users(:working_api_user)
    given_authentication(user)
    post :start
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "running", body["status"]
    assert_equal 1, user.time_entries.length
    assert user.time_entries.first.stopTime.nil?, "expected stopTime to be set correctly"
  end

end
