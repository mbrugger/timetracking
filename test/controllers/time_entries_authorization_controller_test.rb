require 'test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
  tests TimeEntriesController
  include Devise::TestHelpers

  test "admin should be able to browse other users time entries" do
    given_authenticated_user(users(:admin_user))
    get :index, user_id: users(:other_user)
    assert_response :success
    assert_not_nil assigns(:time_entries)
  end

  test "user should not be able to browse other users time entries" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:other_user).id
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "user should be able to browse own time entries" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:user).id
    assert_response :success
  end


end
