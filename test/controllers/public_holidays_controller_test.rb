require 'test_helper'

class PublicHolidaysControllerTest < ActionController::TestCase
  setup do
    @public_holiday = public_holidays(:one)
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:public_holidays)
  # end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #
  # test "should create public_holiday" do
  #   assert_difference('PublicHoliday.count') do
  #     post :create, public_holiday: {  }
  #   end
  #
  #   assert_redirected_to public_holiday_path(assigns(:public_holiday))
  # end
  #
  # test "should show public_holiday" do
  #   get :show, id: @public_holiday
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @public_holiday
  #   assert_response :success
  # end
  #
  # test "should update public_holiday" do
  #   patch :update, id: @public_holiday, public_holiday: {  }
  #   assert_redirected_to public_holiday_path(assigns(:public_holiday))
  # end
  #
  # test "should destroy public_holiday" do
  #   assert_difference('PublicHoliday.count', -1) do
  #     delete :destroy, id: @public_holiday
  #   end
  #
  #   assert_redirected_to public_holidays_path
  # end
end
