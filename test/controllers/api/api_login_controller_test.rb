require 'test_helper'

class ApiLoginControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  tests Api::V1::ApiLoginController

  #curl -v -i -d "" --user "m@brugger.eu:test1234" -H "xContent-Type: application/json" -H cation/json" -X POST http://localhost:3000/api/v1/login

  test "should return token for successful authentication using correct username and password" do
    user = users(:api_user)
    sign_in user
    # test login simulated using default devise test helper
    # authentication can be performed using http basic auth when using API
    #@request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.email, "password")
    post :login
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal body["token"], user.token
  end



  test "should return redirect to login for invalid/missing authentication" do
    post :login
    assert_response :redirect
  end

end
