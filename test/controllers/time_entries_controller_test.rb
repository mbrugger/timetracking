require 'test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup do
    @time_entry_with_report = time_entries(:time_entry_with_report)
    @time_entry_without_report = time_entries(:time_entry_without_report)
    @user = users(:time_entries_controller_user)
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in @user
  end

  test "should get index" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:time_entries)
  end

  test "should get new" do
    get :new, user_id: @user.id
    assert_response :success
  end

  test "should create time_entry" do
    assert_difference('TimeEntry.count') do
      post :create, user_id: @user.id, time_entry: { date: "2012-12-14", start_time_string: "2012-12-14 06:00:00" }
    end

    assert_redirected_to user_time_entries_path(@user, date: "2012-12-14")
  end

  test "should show time_entry" do
    get :show, user_id: @user.id, id: @time_entry_without_report
    assert_response :success
  end

  test "should get edit" do
    get :edit, user_id: @user.id, id: @time_entry_without_report
    assert_response :success
  end

  test "should update time_entry" do
    patch :update, user_id: @user.id, id: @time_entry_without_report, time_entry: {  date: "2012-12-14", start_time_string: "2012-12-14 06:00:00", stop_time_string: "2012-12-14 08:00:00"  }
    assert_redirected_to user_time_entries_path(@user, date:"2012-12-14")
  end

  test "should destroy time_entry" do
    assert_difference('TimeEntry.count', -1) do
      delete :destroy, user_id: @user.id, id: @time_entry_without_report
    end
    assert_redirected_to user_time_entries_path(@user)
  end

# =========== Tests for time entries with existing report ===============

  test "should NOT create time_entry for existing report" do
    assert_no_difference('TimeEntry.count') do
      post :create, user_id: @user.id, time_entry: { date: "2014-11-14", start_time_string: "2014-11-14 06:00:00" }
    end
  end

  test "should NOT get edit for time entry with existing report" do
    get :edit, user_id: @user.id, id: @time_entry_with_report
    assert_response :redirect
    assert_redirected_to user_time_entries_path(@user)
  end

  test "should NOT update time_entry with existig report" do
    patch :update, user_id: @user.id, id: @time_entry_with_report, time_entry: {  date: "2014-12-14", start_time_string: "2014-12-14 06:00:00", stop_time_string: "2012-12-14 08:00:00"  }
    assert_response :success
    assert_equal flash[:alert], "Can not edit time entries if a report already exists, delete report before editing time entry."
    time_entry = TimeEntry.find(@time_entry_with_report.id)
    assert Date.new(2014, 11, 11) == time_entry.date, "time entry must not be modified if report exists"
  end

  test "should NOT update time_entry to date with existig report" do
    patch :update, user_id: @user.id, id: @time_entry_without_report, time_entry: {  date: "2014-11-14", start_time_string: "2014-11-14 06:00:00", stop_time_string: "2012-11-14 08:00:00"  }
    assert_response :success
    assert_equal flash[:alert], "Can not edit time entries if a report already exists, delete report before editing time entry."
    time_entry = TimeEntry.find(@time_entry_without_report.id)
    assert Date.new(2014, 10, 11) == time_entry.date, "time entry must not be modified to date with existing report"
  end

  test "should NOT destroy time_entry with existing report" do
    assert_no_difference('TimeEntry.count') do
      delete :destroy, user_id: @user.id, id: @time_entry_with_report
    end
    assert_response :redirect
    assert_redirected_to user_time_entries_path(@user)
  end

  test "should show validation error for unparseable start time" do
    patch :update, user_id: @user.id, id: @time_entry_without_report, time_entry: {  date: "2014-12-14", start_time_string: "0", stop_time_string: "08:00:00"  }
    assert_response :success
    assert_equal flash[:alert], "Invalid start time 0"
  end

  test "should show validation error for unparseable stop time" do
    patch :update, user_id: @user.id, id: @time_entry_without_report, time_entry: {  date: "2014-12-14", start_time_string: "06:00:00", stop_time_string: "0"  }
    assert_response :success
    assert_equal flash[:alert], "Invalid stop time 0"
  end

end
