require 'test_helper'

class ReportSummariesHelperMigrationTest < ActionView::TestCase
  include ReportSummariesHelper

  def setup
    @current_user = users(:employment_user_migrated)
  end

  test "calculate summary for working days should return correct total balance including migrated balance" do
    working_days = process_working_days(Date.new(2014,12,1), Date.new(2014,12,31), @current_user.time_entries, [], @current_user.employments, [])
    summary = create_report_summary(working_days, @current_user.employments, [])

    assert_duration(0, summary.working_hours)
    assert_duration(177.hours+6.minutes, summary.expected_working_hours)
    assert_duration(-177.hours-6.minutes, summary.working_hours_balance)
    assert_duration(-177.hours-6.minutes+10.hours, summary.total_working_hours_balance)
    assert_duration(10.hours, summary.previous_working_hours_balance)
  end

  test "calculate summary for total_working_hours_balance should consider migrated balance" do
    working_days = process_working_days(Date.new(2014,10,1), Date.new(2014,10,31), @current_user.time_entries, [], @current_user.employments, [])
    summary = create_report_summary(working_days, @current_user.employments, [])
    expected_october_balance = -177.hours-6.minutes
    assert_duration(expected_october_balance, summary.working_hours_balance)
    assert_duration(10.hours, summary.previous_working_hours_balance)
    assert_duration(10.hours+expected_october_balance, summary.total_working_hours_balance)
  end

end
