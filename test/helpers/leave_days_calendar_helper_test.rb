require 'test_helper'

class LeaveDaysCalendarHelperTest < ActionView::TestCase
  include LeaveDaysCalendarHelper

  def assert_leave_day_period(leave_day_period, start_date, end_date)
    assert leave_day_period.start_date == start_date, "expected start_date to be #{start_date}, got #{leave_day_period.start_date}"
    assert leave_day_period.end_date == end_date, "expected end_date to be #{end_date}, got #{leave_day_period.end_date}"
  end

  test 'aggregate single leave day should create leave_day_period' do
    leave_day_periods = aggregate_leave_day_periods([leave_days(:adi_leave_day_1)])
    assert leave_day_periods.size == 1, "expected one leave day period got #{leave_day_periods}"
    assert_leave_day_period(leave_day_periods[0], leave_days(:adi_leave_day_1).date, leave_days(:adi_leave_day_1).date)

  end

  test 'aggregate multiple connected leave day should create leave_day_period' do
    leave_day_periods = aggregate_leave_day_periods([leave_days(:adi_leave_day_1), leave_days(:adi_leave_day_2)])
    assert leave_day_periods.size == 1, "expected one leave day period got #{leave_day_periods}"
    assert_leave_day_period(leave_day_periods[0], leave_days(:adi_leave_day_1).date, leave_days(:adi_leave_day_2).date)
  end

  test 'aggregate multiple not connected leave day should create multiple leave_day_periods' do
    leave_day_periods = aggregate_leave_day_periods([leave_days(:adi_leave_day_1), leave_days(:adi_leave_day_2), leave_days(:adi_leave_day_3), leave_days(:adi_leave_day_4)])
    assert leave_day_periods.size == 2, "expected two leave day periods got #{leave_day_periods}"
    assert_leave_day_period(leave_day_periods[0], leave_days(:adi_leave_day_1).date, leave_days(:adi_leave_day_2).date)
    assert_leave_day_period(leave_day_periods[1], leave_days(:adi_leave_day_3).date, leave_days(:adi_leave_day_4).date)
  end

  test 'aggregate without leave day should create no leave_day_period' do
    leave_day_periods = aggregate_leave_day_periods([])
    assert leave_day_periods.size == 0, "expected no leave day period got #{leave_day_periods}"
  end

end
