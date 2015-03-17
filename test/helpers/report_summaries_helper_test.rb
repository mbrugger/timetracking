require 'test_helper'

class ReportSummariesHelperTest < ActionView::TestCase
  include ReportSummariesHelper

  def setup
    @current_user = users(:admin)
    @working_days = create_working_days()
  end

  test "calculate summary for working days should return correct summary with expected and actual working hours" do
    summary = create_report_summary(@working_days, @current_user.employments, [])
    assert !summary.nil?, "expected summary"
    assert_duration((6+7).hours, summary.working_hours)
    assert_duration((8*2).hours,summary.expected_working_hours)
  end

  test "calculate summary for working days should return correct total balance including previous report correction" do
    working_days = process_working_days(Date.new(2014,12,1), Date.new(2014,12,31), @current_user.time_entries, [], @current_user.employments, [])
    summary = create_report_summary(working_days, [employments(:november_open_end)], [reports(:admin_november)])

    assert_duration(19.hours+29.minutes, summary.working_hours)
    assert_duration(184.hours, summary.expected_working_hours)
    assert_duration(-164.hours-31.minutes, summary.working_hours_balance)
    assert_duration(-164.hours-31.minutes+5.hours, summary.total_working_hours_balance)
    assert_duration(5.hours, summary.previous_working_hours_balance)
  end

  test "calculate summary for working days should return correct total balance including current report correction" do
    working_days = process_working_days(Date.new(2014,12,1), Date.new(2014,12,31), @current_user.time_entries, [], @current_user.employments, [])
    summary = create_report_summary(working_days, [employments(:november_open_end)], [reports(:admin_november), reports(:admin_december)])

    assert_duration(19.hours+29.minutes, summary.working_hours)
    assert_duration(184.hours, summary.expected_working_hours)
    assert_duration(-164.hours-31.minutes, summary.working_hours_balance)
    assert_duration(-164.hours-31.minutes+5.hours+150.hours, summary.total_working_hours_balance)
  end

  test "calculate summary with working days with validation error should return validation_errors" do
    time_entries = []
    time_entries << time_entries(:wd_open)
    time_entries +=  @current_user.time_entries
    working_days = process_working_days(Date.new(2014,12,1), Date.new(2014,12,31), time_entries, [], @current_user.employments, [])
    summary = create_report_summary(working_days, [employments(:november_open_end)], [reports(:admin_november), reports(:admin_december)])
    assert summary.validation_errors? == true, "expected validation errors"
  end

  test "calculate summary shoud consider comp_time in balance" do
    working_days = process_working_days(Date.new(2014,12,1), Date.new(2014,12,31), @current_user.time_entries, [leave_days(:comp_time)], @current_user.employments, [])
    summary = create_report_summary(working_days, [employments(:november_open_end)], [reports(:admin_november), reports(:admin_december)])

    assert_duration(19.hours+29.minutes, summary.working_hours)
    assert_duration(176.hours, summary.expected_working_hours)
    assert_duration(-164.hours-31.minutes, summary.working_hours_balance)
    assert_duration(-164.hours-31.minutes+5.hours+150.hours, summary.total_working_hours_balance)
  end

  test "calculate summary shoud calculate comp_time" do
    working_days = process_working_days(Date.new(2014,12,1), Date.new(2014,12,31), @current_user.time_entries, [leave_days(:comp_time)], @current_user.employments, [])
    #puts "working_days: #{working_days.inspect}"
    summary = create_report_summary(working_days, [employments(:november_open_end)], [reports(:admin_november), reports(:admin_december)])
    assert_duration(8.hours, summary.comp_time)
  end

  test "calculate summary should create empty summary for empty working days" do
    working_days = []
    summary = create_report_summary(working_days, [employments(:november_open_end)], [reports(:admin_november), reports(:admin_december)])
    assert_duration(0.hours, summary.working_hours)
    assert_duration(0.hours, summary.expected_working_hours)
    assert_duration(0.hours, summary.working_hours_balance)
    assert_duration(0.hours, summary.comp_time)
  end


end
