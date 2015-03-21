require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @report = reports(:one)
  end

  def setup
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    @current_user = users(:unemployed_admin)
    sign_in @current_user
  end

  test "should get current report for logged in user should fail with no employment warning" do
    get :current, user_id: @current_user.id
    assert_equal flash[:alert], "Please ask your administrator to create an employment first."
  end

  test "should get current report for other user should fail with no employment warning" do
    get :current, user_id: users(:unemployed_user).id
    assert_equal flash[:alert], "Please create an employment for this user first."
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
