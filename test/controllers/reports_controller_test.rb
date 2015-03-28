require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "admin should be able to browse other users reports" do
    given_authenticated_user(users(:admin_user))
    get :index, user_id: users(:other_user)
    assert_response :success
    assert_not_nil assigns(:reports)
  end

  test "user should not be able to browse other users reports" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:other_user).id
    assert_redirected_to locale_root_path
    assert_equal "You are not authorized to access this page.", flash[:alert]
  end

  test "user should be able to browse own reports" do
    given_authenticated_user(users(:user))
    get :index, user_id: users(:user).id
    assert_response :success
  end

  test "should get current report for logged in user should fail with no employment warning" do
    given_authenticated_user(users(:unemployed_admin))
    get :current, user_id: @current_user.id
    assert_equal flash[:alert], "Please ask your administrator to create an employment first."
  end

  test "should get current report for other user should fail with no employment warning" do
    given_authenticated_user(users(:unemployed_admin))
    get :current, user_id: users(:unemployed_user).id
    assert_equal flash[:alert], "Please create an employment for this user first."
  end

  test "should fail fetching another users report content if not admin" do
    given_authenticated_user(users(:user_adi))
    get :content, user_id: users(:employment_user).id, year: 2015, month: 2
    assert_equal "You are not authorized to access this page.", flash[:alert]
    assert_redirected_to locale_root_path
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:reports)
  # end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #
  # test "should create report" do
  #   assert_difference('Report.count') do
  #     post :create, report: {  }
  #   end
  #
  #   assert_redirected_to report_path(assigns(:report))
  # end
  #
  # test "should show report" do
  #   get :show, id: @report
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @report
  #   assert_response :success
  # end
  #
  # test "should update report" do
  #   patch :update, id: @report, report: {  }
  #   assert_redirected_to report_path(assigns(:report))
  # end
  #
  # test "should destroy report" do
  #   assert_difference('Report.count', -1) do
  #     delete :destroy, id: @report
  #   end
  #
  #   assert_redirected_to reports_path
  # end
end
