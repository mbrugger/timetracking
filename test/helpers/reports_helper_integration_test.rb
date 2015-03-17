require 'test_helper'

class ReportsHelperIntegrationTest < ActionView::TestCase

  def setup
    @controller = ReportsController.new
    @current_user = users(:tester)
    @public_holidays = [public_holidays(:august_15th)]
    @leave_days = [leave_days(:tester_leave_day_1), leave_days(:tester_leave_day_2)]
    @employments = [employments(:august_open_end)]
    @reports = [reports(:tester_august)]
    @expected_august_balance = (8*3).hours - (38.5/5*(21-3)).hours
    @expected_september_balance = -169.hours-24.minutes
  end

  test "calculate august report should calculate correctly" do
    working_days = @controller.process_working_days(Date.new(2014,8,1), Date.new(2014,8,31),
            @current_user.time_entries, @current_user.leave_days, @current_user.employments, @public_holidays)
    summary = @controller.create_report_summary(working_days, @current_user.employments, [])
    assert_duration((3*8).hours, summary.working_hours)
    assert_duration((38.5/5*(21-3)).hours, summary.expected_working_hours)
    assert_duration(@expected_august_balance, summary.working_hours_balance)
  end

  test "calculate august report should calculate balance correctly" do
    working_days = @controller.process_working_days(Date.new(2014,8,1), Date.new(2014,8,31),
            @current_user.time_entries, @current_user.leave_days, @current_user.employments, @public_holidays)
    summary = @controller.create_report_summary(working_days, @current_user.employments, [])
    assert_duration(@expected_august_balance, summary.working_hours_balance)
  end

  test "calculate september report should calculate total balance correctly for existing august report" do
    working_days = @controller.process_working_days(Date.new(2014,9,1), Date.new(2014,9,30),
            @current_user.time_entries, @current_user.leave_days, @current_user.employments, @public_holidays)
    summary = @controller.create_report_summary(working_days, @current_user.employments, @current_user.reports)
    assert @current_user.reports.size > 0
    assert_duration(@expected_august_balance, summary.previous_working_hours_balance)
    assert_duration(@expected_september_balance, summary.working_hours_balance)
    assert_duration(@expected_august_balance+@expected_september_balance, summary.total_working_hours_balance, "total balance")
  end

  test "validation of time entries after employment end should not create missing time entries validaiton error" do
    user = users(:admin)
    employment = employments(:first_half_august)
    working_days = @controller.process_working_days(Date.new(2014,9,1), Date.new(2014,9,30),
    user.time_entries, user.leave_days, [employment], @public_holidays)
    assert working_days.first.validation_errors.size == 0, "no validation errors expected got: #{working_days.first.validation_errors}"
  end

end
