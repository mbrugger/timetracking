require 'test_helper'

class ReportsHelperWorkingDayTest < ActionView::TestCase

  include ReportsHelper

  def setup

  end

  def given_time_entries(time_entries)
    @working_day = prepare_working_days_for_time_entries(time_entries).values.first
  end

  def given_leave_day()
    given_working_day_without_time_entries()
    @working_day.expected_duration = 0.hours
  end

  def given_working_day_without_time_entries()
    @working_day = WorkingDay.new(Date.new(2014,12,12))
    @working_day.expected_duration = 8.hours
  end

  def given_working_day_without_time_entries_today()
    @working_day = WorkingDay.new(Date.today)
    @working_day.expected_duration = 8.hours
  end

  def given_working_day_without_time_entries_tomorrow()
    @working_day = WorkingDay.new(Date.tomorrow)
    @working_day.expected_duration = 8.hours
  end

  def when_validation_is_performed
    @result = calculate_single_day_validation_errors(@working_day)
  end

  def then_validation_result_is(expected_result)
    assert @result == expected_result, "Expected #{expected_result} got #{@result}"
  end

  test "calculate_single_day_validation_errors should return empty array for correct working day" do
      given_time_entries([time_entries(:wd_morning),time_entries(:wd_afternoon)])
      when_validation_is_performed
      then_validation_result_is([])
  end

  test "calculate_single_day_validation_errors should return error for overlapping time entries" do
    given_time_entries([time_entries(:wd_afternoon), time_entries(:wd_long_morning)])
    when_validation_is_performed
    then_validation_result_is(['Overlapping time entries'])
  end

  test "calculate_single_day_validation_errors should return error for negative duration" do
    given_time_entries([time_entries(:wd_negative)])
    when_validation_is_performed
    then_validation_result_is(['Invalid duration'])
  end

  test "calculate_single_day_validation_errors should return error for duration exceeding daily limit" do
    given_time_entries([time_entries(:wd_morning), time_entries(:wd_long_afternoon)])
    when_validation_is_performed
    then_validation_result_is(['Duration exceeding daily limit'])
  end

  test "calculate_single_day_validation_errors should return error for early start time exceeding limit" do
    given_time_entries([time_entries(:wd_early_morning)])
    when_validation_is_performed
    then_validation_result_is(['Invalid start time'])
  end

  test "calculate_single_day_validation_errors should return error for late stop time exceeding limit" do
    given_time_entries([time_entries(:wd_afternoon_night)])
    when_validation_is_performed
    then_validation_result_is(['Invalid stop time'])
  end

  test "calculate_single_day_validation_errors should return error missing stop time" do
    given_time_entries([time_entries(:wd_open)])
    when_validation_is_performed
    then_validation_result_is(['Missing stop time'])
  end

  test "calculate_single_day_validation_errors should NOT return error missing stop time at current date" do
    given_time_entries([time_entries(:wd_open_today)])
    # run test only during valid working hours
    if DateTime.now.hour > 7 and DateTime.now.hour < 20
      when_validation_is_performed
      then_validation_result_is([])
    end
  end

  test "calculate_single_day_validation_errors should return error for missing time entries without leave day" do
    given_working_day_without_time_entries()
    when_validation_is_performed
    then_validation_result_is(['Missing time entries'])
  end

  test "calculate_single_day_validation_errors should NOT return error for missing time entries today" do
    given_working_day_without_time_entries_today()
    when_validation_is_performed
    then_validation_result_is([])
  end

  test "calculate_single_day_validation_errors should NOT return error for missing time entries at future date" do
    given_working_day_without_time_entries_tomorrow()
    when_validation_is_performed
    then_validation_result_is([])
  end

  test "calculate_single_day_validation_errors should NOT return error for missing time entries with leave day" do
    given_leave_day()
    when_validation_is_performed
    then_validation_result_is([])
  end

end
