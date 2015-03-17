require 'test_helper'

class ReportsHelperTest < ActionView::TestCase

  def setup
    @controller = HomeController.new
    @current_user = users(:admin)
    @public_holidays = [public_holidays(:december_8th), public_holidays(:december_25th)]
    @leave_days = [leave_days(:leave_day), leave_days(:sick_day), leave_days(:comp_time)]
    @employments = [employments(:december_open_end)]
    @working_days = create_working_days()
  end

  test "process_working_days should return list of working days" do
    result = @controller.process_working_days(Date.new(2014,12,1),Date.new(2014,12,31),[],[],@employments,[])
    assert result.size == 31, "expected 31 working days but got #{result.size}"
  end

  test "prepare working days for time entries should group time entries by date" do
    time_entries = [time_entries(:first_day_1), time_entries(:first_day_2), time_entries(:second_day_1)]
    result = @controller.prepare_working_days_for_time_entries(time_entries)
    assert result.size == 2, "expected 2 working days"
    assert result[time_entries(:first_day_1).date].date == time_entries(:first_day_1).date
    assert result[time_entries(:first_day_1).date].time_entries.size == 2
    assert result[time_entries(:second_day_1).date].date == time_entries(:second_day_1).date
    assert result[time_entries(:second_day_1).date].time_entries.size == 1
  end

  test "process working day should correctly calculate the duration" do
    time_entries = [time_entries(:first_day_1), time_entries(:first_day_2), time_entries(:second_day_1)]
    working_days = @controller.prepare_working_days_for_time_entries(time_entries)
    working_day = working_days[time_entries(:first_day_1).date]
    @controller.process_working_day(working_day, [], [], @employments)
    assert_duration(4*60*60, working_day.duration, "expected 4 hours of working time")
  end

  # ============== calculate_single_day_working_hours

  test "calculate single day working hours should return zero for no time entries" do
    result = @controller.calculate_single_day_working_hours([])
    assert_duration(0, result, "expected zero working hours")
  end

  test "calculate single day working hours should return duration for single time entry" do
    time_entry = time_entries(:closed)
    result = @controller.calculate_single_day_working_hours([time_entry])
    assert_duration(2*60*60, result, "expected 2 working hours")
  end

  test "calculate single day working hours should return duration for multiple time entries" do
    time_entry = time_entries(:closed)
    result = @controller.calculate_single_day_working_hours([time_entry, time_entry, time_entry])
    assert_duration(6*60*60, result, "expected 6 working hours")
  end

  # ============== evaluate_working_day_status

  test "evaluate_working_day_status should return false for saturdays" do
    working_day = WorkingDay.new(Date.new(2014,12,6))
    @controller.evaluate_working_day_status(working_day, [], [])
    assert working_day.working_day? == false, "saturday is not a working day"
  end

  test "evaluate_working_day_status should return false for sundays" do
    working_day = WorkingDay.new(Date.new(2014,12,7))
    @controller.evaluate_working_day_status(working_day, [], [])
    assert working_day.working_day? == false, "sunday is not a working day"
  end

  test "evaluate_working_day_status should return false for holiday" do
    working_day = WorkingDay.new(Date.new(2014,12,8))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    assert working_day.working_day? == false, "2014-12-8 is not a working day"
  end

  test "evaluate_working_day_status should return false for leave day" do
    working_day = WorkingDay.new(Date.new(2014,12,24))
    @controller.evaluate_working_day_status(working_day, @public_holidays, @leave_days)
    assert working_day.working_day? == false, "2014-12-8 is not a working day"
  end

  test "evaluate_working_day_status should return true for real working day" do
    working_day = WorkingDay.new(Date.new(2014,12,9))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    assert working_day.working_day? == true, "2014-12-9 is a working day"
  end

  test "evaluate_working_day_status should return false for comp time" do
    working_day = WorkingDay.new(Date.new(2014,12,30))
    @controller.evaluate_working_day_status(working_day, @public_holidays, @leave_days)
    assert working_day.working_day? == false, "2014-12-30 is not a working day"
  end

  # ============== calculate_expected_working_day_hours

  test "calculate_expected_working_day_hours should return 0:00 for comp_time day" do
    working_day = WorkingDay.new(Date.new(2014,12,30))
    @controller.evaluate_working_day_status(working_day, @public_holidays, @leave_days)
    result = @controller.calculate_working_day_expected_hours(working_day, @leave_days, @public_holidays, @employments)
    assert_duration(0, result)
  end

  test "calculate_expected_working_day_hours should return zero for weekend" do
    working_day = WorkingDay.new(Date.new(2014,12,7))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    result = @controller.calculate_working_day_expected_hours(working_day, @leave_days, @public_holidays, @employments)
    assert_duration(0, result, "expected 0 hours for weekend got #{result}")
  end

  test "calculate_expected_working_day_hours should return zero for leave day" do
    working_day = WorkingDay.new(Date.new(2014,12,24))
    @controller.evaluate_working_day_status(working_day, @public_holidays, @leave_days)
    result = @controller.calculate_working_day_expected_hours(working_day, @leave_days, @public_holidays, @employments)
    assert_duration(0, result, "expected 0 hours for leave day, #{working_day.inspect}")
  end

  test "calculate_expected_working_day_hours should return zero for public holiday" do
    working_day = WorkingDay.new(Date.new(2014,12,25))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    result = @controller.calculate_working_day_expected_hours(working_day, @leave_days, @public_holidays, @employments)
    assert_duration(0, result, "expected 0 hours for public holiday")
  end

  test "calculate_expected_working_day_hours should return 0:00 if not employed at that date" do
    working_day = WorkingDay.new(Date.new(2011,12,9))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    result = @controller.calculate_working_day_expected_hours(working_day, @leave_days, @public_holidays, @employments)
    assert_duration(0, result, "expected 0 hours for not employed day")
  end

  test "calculate_expected_working_day_hours should return 8:00 for working day" do
    working_day = WorkingDay.new(Date.new(2014,12,9))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    result = @controller.calculate_working_day_expected_hours(working_day, @leave_days, @public_holidays, @employments)
    assert_duration(8.hours, result, "expected 8 hours for 40 hours week")
  end

  test "calculate_expected_working_hours should return sum of all expected working hours" do
    calculated_working_hours = @controller.calculate_expected_working_hours(@working_days)
    assert_duration(8*2.hours, calculated_working_hours)
  end

  test "calculate_expected_working_hours should return zero for empty list" do
    calculated_working_hours = @controller.calculate_expected_working_hours([])
    assert_duration(0, calculated_working_hours)
  end

  test "calculate_working_hours should return sum of all working hours" do
    calculated_working_hours = @controller.calculate_working_hours(@working_days)
    assert_duration((6+7) * 3600.0, calculated_working_hours)
  end

  test "calculate_working_hours should return zero for empty list" do
    calculated_working_hours = @controller.calculate_working_hours([])
    assert_duration(0, calculated_working_hours)
  end

  # ============== calculate_working_day_default_hours

  test "calculate_working_day_default_hours should return 8:00 for working day" do
    working_day = WorkingDay.new(Date.new(2014,12,9))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    result = @controller.calculate_working_day_default_hours(working_day, @employments)
    assert_duration(8.hours, result)
  end

  test "calculate_working_day_default_hours should return 8:00 for leave day" do
    working_day = WorkingDay.new(Date.new(2014,12,24))
    @controller.evaluate_working_day_status(working_day, @public_holidays, @leave_days)
    result = @controller.calculate_working_day_default_hours(working_day, @employments)
    assert_duration(8.hours, result)
  end

  test "calculate_working_day_default_hours should return 0:00 if not employed at that date" do
    working_day = WorkingDay.new(Date.new(2011,12,9))
    @controller.evaluate_working_day_status(working_day, @public_holidays, [])
    result = @controller.calculate_working_day_default_hours(working_day, @employments)
    assert_duration(0, result)
  end

  # ============== calculate_single_day_pause_hours

  test "calculate_single_day_pause_hours should return zero for workday without time entries" do
    calculated_pause_hours = @controller.calculate_single_day_pause_hours([])
    assert_duration(0, calculated_pause_hours)
  end

  test "calculate_single_day_pause_hours should return zero for workday with subsequent time entries" do
    calculated_pause_hours = @controller.calculate_single_day_pause_hours([time_entries(:admin_time_entry_1), time_entries(:admin_time_entry_2)])
    assert_duration(0, calculated_pause_hours)
  end

  test "calculate_single_day_pause_hours should return 2:00 for workday with time entries and pause time" do
    calculated_pause_hours = @controller.calculate_single_day_pause_hours([time_entries(:admin_time_entry_1), time_entries(:admin_time_entry_3)])
    assert_duration(2.hours, calculated_pause_hours)
  end

  #============== reduction of working_hours by forced pause

  test "process_working_day should return 2:00 pause duration for workday with time entries and pause time" do
    working_day = WorkingDay.new(time_entries(:admin_time_entry_1).date)
    working_day.add_time_entry(time_entries(:admin_time_entry_1))
    working_day.add_time_entry(time_entries(:admin_time_entry_3))
    @controller.process_working_day(working_day, [], [], @employments)
    assert_duration(2.hours, working_day.pause_duration)
  end

  test "process_working_day should return 0:30 pause for workday with single time entry >= 6:00" do
    working_day = WorkingDay.new(time_entries(:admin_time_entry_6hr).date)
    working_day.add_time_entry(time_entries(:admin_time_entry_6hr))
    @controller.process_working_day(working_day, [], [], @employments)
    assert_duration(30.minutes, working_day.pause_duration)
  end

  test "process_working_day should return 0:30 pause for workday with subsequent time entries >= 6:00" do
    working_day = WorkingDay.new(time_entries(:admin_time_entry_1).date)
    working_day.add_time_entry(time_entries(:admin_time_entry_1))
    working_day.add_time_entry(time_entries(:admin_time_entry_3))
    working_day.add_time_entry(time_entries(:admin_time_entry_2))
    @controller.process_working_day(working_day, [], [], @employments)
    assert_duration(30.minutes, working_day.pause_duration)
  end

  test "process_working_day should return 0:00 pause for workday with single time entry < 6:00" do
    working_day = WorkingDay.new(time_entries(:admin_time_entry_5h59).date)
    working_day.add_time_entry(time_entries(:admin_time_entry_5h59))
    @controller.process_working_day(working_day, [], [], @employments)
    assert_duration(0.minutes, working_day.pause_duration)
  end

  test "report_for_date should return report" do
    existing_report = Report.new
    existing_report.date = Date.new(2014,12,1)
    report = report_for_date(Date.new(2014,12,24), [existing_report])
    assert report == existing_report, "expected report to be retrieved"
  end

  test "report_for_date should not return report if no matching report exists" do
    existing_report = Report.new
    existing_report.date = Date.new(2014,11,1)
    report = report_for_date(Date.new(2014,12,24), [existing_report])
    assert report == nil, "no report expected"
  end

end
