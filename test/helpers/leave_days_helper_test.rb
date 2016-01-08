require 'test_helper'

class LeaveDaysHelperTest < ActionView::TestCase
  include LeaveDaysHelper

  def setup
    @current_user = users(:employment_user)
    @start_date = Date.new(2015,1,1)
  end

  def assert_days(expected, actual, additional_message = nil)
    message = "expected: #{expected} got: #{actual}"
    message += " #{additional_message}" unless additional_message.nil?
    assert expected == actual, message
  end

  def end_date(start_date, contract_duration)
    return start_date + contract_duration - 1.day
  end

  def calculate_obtained_leave_days_for_dates_with_contract_end(start_date, end_date, current_date)
    employment = Employment.new
    employment.startDate = start_date
    employment.endDate = end_date
    return calculate_obtained_leave_days(current_date, [employment])
  end

  # ======== helper method test ============

  test "calculate employment months should return 0 from 2014-3-3 to 2014-3-3 on the first day" do
    employment_months = calculate_employment_months(Date.new(2014,3,3), Date.new(2014,3,3))
    assert employment_months == 0, "expected 0 months got #{employment_months}"
  end

  test "calculate employment months should return 11 from 2014-3-3 to 2015-3-2" do
    employment_months = calculate_employment_months(Date.new(2014,3,3), Date.new(2015,3,2))
    assert employment_months == 11, "expected 11 months got #{employment_months}"
  end

  test "calculate employment months should return 11 from 2014-3-3 to 2015-2-3" do
    employment_months = calculate_employment_months(Date.new(2014,3,3), Date.new(2015,2,3))
    assert employment_months == 11, "expected 11 months got #{employment_months}"
  end

  test "calculate employment months should return 12 from 2014-3-3 to 2015-3-3" do
    employment_months = calculate_employment_months(Date.new(2014,3,3), Date.new(2015,3,3))
    assert employment_months == 12, "expected 12 months got #{employment_months}"
  end

  test "calculate employment months should return 12 from 2014-3-3 to 2015-3-4" do
    employment_months = calculate_employment_months(Date.new(2014,3,3), Date.new(2015,3,4))
    assert employment_months == 12, "expected 12 months got #{employment_months}"
  end

  # ======== calculate_available_leave_days -> migrated from calculate_obtained_leave_days(old) ===========

  test "calculate_available_leave_days should start with 2 leave days at employment start" do
    leave_days = calculate_available_leave_days(Date.new(2014,8,1), [employments(:default_employment)], [])
    assert_days(2, leave_days)
  end

  test "calculate_available_leave_days should calculate a full yearly leave days available after 6 months" do
    leave_days = calculate_available_leave_days(Date.new(2015,2,1), [employments(:default_employment)], [])
    assert_days(25, leave_days)
  end

  test "calculate_available_leave_days should calculate 2 leave days per month for the first 6 employment months" do
    leave_days = calculate_available_leave_days(Date.new(2014,10,1), [employments(:default_employment)], [])
    assert_days(6, leave_days)
  end

  test "calculate_available_leave_days should add 25 leave days per year employed on working year start" do
    leave_days = calculate_available_leave_days(Date.new(2015,8,1), [employments(:default_employment)], [])
    assert_days(25+25, leave_days)
  end

  test "calculate_available_leave_days should add 25 leave days per year employed not before working year start" do
    leave_days = calculate_available_leave_days(Date.new(2015,7,31), [employments(:default_employment)], [])
    assert_days(25, leave_days)
  end

  test "calculate_available_leave_days should add 25 leave days not before working year start for migrated employee" do
    leave_days = calculate_available_leave_days(Date.new(2015,7,31), [employments(:migrated_employment), employments(:original_employment)], [])
    assert_days(30, leave_days)
  end

  test "calculate_available_leave_days should add 25 days on working year start including available leave days from other time tracking system" do
    leave_days = calculate_available_leave_days(Date.new(2015,8,1), [employments(:migrated_employment), employments(:original_employment)], [])
    assert_days(55, leave_days)
  end

  test "calculate_available_leave_days should not add leave days after employment end" do
    leave_days = calculate_available_leave_days(Date.new(2017,8,31), [employments(:terminated_employment)], [])
    assert_days(75, leave_days)
  end

  # ======================= calculate_available_leave_days =====================

  test "calculate_available_leave_days should return all obtained leave days if no leave days have been consumed" do
    available_leave_days = calculate_available_leave_days(Date.new(2014,8,31), [employments(:default_employment)], @current_user.leave_days)
    assert_days(2, available_leave_days)
  end

  test "calculate_available_leave_days should return obtained leave days minus used leave days" do
    available_leave_days = calculate_available_leave_days(Date.new(2014,9,30), [employments(:default_employment)], @current_user.leave_days)
    assert_days(2, available_leave_days)
  end

  test "calculate_available_leave_days should not reduce leave days for sick days and absent days" do
    available_leave_days = calculate_available_leave_days(Date.new(2014,10,31), [employments(:default_employment)], @current_user.leave_days)
    assert_days(4, available_leave_days)
  end

  test "calculate_available_leave_days should not reduce leave days for future leave days" do
    available_leave_days = calculate_available_leave_days(Date.new(2015,8,1), [employments(:default_employment)], @current_user.leave_days)
    assert_days(50-2, available_leave_days)
  end

  # === migration scenarios

  test "calculate_available_leave_days is not supported in migrated employment" do
    assert_raises ArgumentError do
      available_leave_days = calculate_available_leave_days(Date.new(2014,9,30), [employments(:migrated_employment), employments(:original_employment)], [])
    end
  end

  test "calculate_available_leave_days should consider leave days balance for migrated employments" do
    available_leave_days = calculate_available_leave_days(Date.new(2014,10,1), [employments(:migrated_employment), employments(:original_employment)], [])
    assert_days(30, available_leave_days)
  end

  test "calculate_available_leave_days should add new leave days on working year start also for migrated employees" do
    available_leave_days = calculate_available_leave_days(Date.new(2015,8,1), [employments(:migrated_employment), employments(:original_employment)], [])
    assert_days(55, available_leave_days)
  end

  # ======================= calculate_consumed_leave_days ======================

  test "calculate_consumed_leave_days should calculate consumed leave days in current working year" do
    consumed_leave_days = calculate_consumed_leave_days(Date.new(2014,10,31), [employments(:default_employment)], @current_user.leave_days)
    assert_days(2, consumed_leave_days)
  end

  test "calculate_consumed_leave_days should calculate consumed leave days in future working year without current year" do
    consumed_leave_days = calculate_consumed_leave_days(Date.new(2016,10,31), [employments(:default_employment)], @current_user.leave_days)
    assert_days(1, consumed_leave_days)
  end

  # ======================= calculate_working_year_start =======================

  test "working_year_start should calculate the working year start based on the employment start for the first year" do
    working_year_start = calculate_working_year_start(Date.new(2014,10,31), employments(:default_employment).startDate)
    assert Date.new(2014,8,1) == working_year_start, "got #{working_year_start}"
  end

  test "working_year_start should calculate the working year start based on the employment start for the yearly second year" do
    working_year_start = calculate_working_year_start(Date.new(2015,7,31), employments(:default_employment).startDate)
    assert Date.new(2014,8,1) == working_year_start, "got #{working_year_start}"
  end

  test "working_year_start should calculate the working year start based on the employment start" do
    working_year_start = calculate_working_year_start(Date.new(2016,10,31), employments(:original_employment).startDate)
    assert Date.new(2016,8,1) == working_year_start, "got #{working_year_start}"
  end

  # ======================= calculate_obtained_leave_days_for_dates ============

  test "calculate_obtained_leave_days_for_dates should return 2 for first month" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2014,1,31))
    assert_days(2, obtained_leave_days)
  end

  test "calculate_obtained_leave_days_for_dates should return 4 for second month" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2014,2,28))
    assert_days(4, obtained_leave_days)
  end

  test "calculate_obtained_leave_days_for_dates should return 12 for 6th month" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2014,6,30))
    assert_days(12, obtained_leave_days)
  end

  test "calculate_obtained_leave_days_for_dates should return 25 for 7th month" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2014,7,31))
    assert_days(25, obtained_leave_days)
  end

  test "calculate_obtained_leave_days_for_dates should return 25 for 8th month" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2014,8,31))
    assert_days(25, obtained_leave_days)
  end

  test "calculate_obtained_leave_days_for_dates should return 25 for the last day of the first year" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2014,12,31))
    assert_days(25, obtained_leave_days)
  end

  test "calculate_obtained_leave_days_for_dates should return 50 for second working year start" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2015,1,1))
    assert_days(50, obtained_leave_days)
  end

  test "calculate_obtained_leave_days_for_dates should return 50 for second working year end" do
    obtained_leave_days = calculate_obtained_leave_days_for_dates(Date.new(2014,1,1), Date.new(2015,12,31))
    assert_days(50, obtained_leave_days)
  end


  # ======================= migration related tests ============
  test "calculate summary should correctly consider leave days for migrated users within 6 months of employment" do
    public_holidays = PublicHoliday.all
    @current_user = users(:user_adi)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,1,31), @current_user.employments, @current_user.leave_days)
    @leave_days_consumed = calculate_consumed_leave_days(Date.new(2015,1,31), @current_user.employments, @current_user.leave_days)
    assert @leave_days_consumed == 7, "expected 7 got #{@leave_days_consumed}"
    assert @leave_days_available == 3, "expected 3 got #{@leave_days_available}"
  end

  test "calculate summary should correctly consider leave days for migrated users special case resi at last day of first working year" do
    public_holidays = PublicHoliday.all
    @current_user = users(:user_resi)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,3,3), @current_user.employments, @current_user.leave_days)
    @leave_days_consumed = calculate_consumed_leave_days(Date.new(2015,3,3), @current_user.employments, @current_user.leave_days)
    assert @leave_days_consumed == 0, "expected 0 got #{@leave_days_consumed}"
    assert @leave_days_available == 25, "expected 25 got #{@leave_days_available}"
  end

  test "calculate summary should correctly consider leave days for migrated users special case resi at first day of second working year" do
    public_holidays = PublicHoliday.all
    @current_user = users(:user_resi)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,3,4), @current_user.employments, @current_user.leave_days)
    @leave_days_consumed = calculate_consumed_leave_days(Date.new(2015,3,4), @current_user.employments, @current_user.leave_days)
    assert @leave_days_consumed == 0, "expected 0 got #{@leave_days_consumed}"
    assert @leave_days_available == 50, "expected 50 got #{@leave_days_available}"
  end

  test "calculate summary should correctly consider leave days for migrated users special case resi at 2015-03-31" do
    public_holidays = PublicHoliday.all
    @current_user = users(:user_resi)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,3,31), @current_user.employments, @current_user.leave_days)
    @leave_days_consumed = calculate_consumed_leave_days(Date.new(2015,3,31), @current_user.employments, @current_user.leave_days)
    assert @leave_days_consumed == 0, "expected 0 got #{@leave_days_consumed}"
    assert @leave_days_available == 50, "expected 50 got #{@leave_days_available}"
  end

  # ======================= scenario contract termination available leave days calculation =======================

  test "calculate available leave days if employment is terminated after 5 months" do
    @current_user = users(:terminated_after_5_month_user)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,6,30), @current_user.employments, @current_user.leave_days)
    assert_equal 10, @leave_days_available
  end

  test "calculate available leave days if employment is terminated after 5 months at future date" do
    @current_user = users(:terminated_after_5_month_user)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,8,30), @current_user.employments, @current_user.leave_days)
    assert_equal 10, @leave_days_available
  end

  test "calculate available leave days if employment is terminated after 5 months and user is migrated" do
    @current_user = users(:migrated_terminated_after_5_month_user)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,8,30), @current_user.employments, @current_user.leave_days)
    assert_equal 10, @leave_days_available
  end

  test "calculate available leave days if employment is terminated after 11 months" do
    @current_user = users(:terminated_after_11_month_user)
    @leave_days_available = calculate_available_leave_days(Date.new(2015,12,31), @current_user.employments, @current_user.leave_days)
    assert_equal 22, @leave_days_available
  end

  test "calculate available leave days if employment is terminated after 11 months checked at future date" do
    @current_user = users(:terminated_after_11_month_user)
    @leave_days_available = calculate_available_leave_days(Date.new(2016,1,31), @current_user.employments, @current_user.leave_days)
    assert_equal 22, @leave_days_available
  end

  test "calculate available leave days if employment is terminated after 18 months and employment has been changed in between" do
    @current_user = users(:terminated_after_18_month_user)
    @leave_days_available = calculate_available_leave_days(Date.new(2016,7,31), @current_user.employments, @current_user.leave_days)
    assert_equal 25+6*2, @leave_days_available
  end

  test "calculate obtained leave days with contract end date for 3 months contract before contract end" do
    @end_date = end_date(@start_date, 3.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date - 2.month)
    assert_equal 2, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 3 months contract at contract end" do
    @end_date = end_date(@start_date, 3.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date)
    assert_equal 6, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 3 months contract after contract end" do
    @end_date = end_date(@start_date, 3.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date + 1.month)
    assert_equal 6, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 11 months contract before contract end" do
    @end_date = end_date(@start_date, 11.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date - 2.month)
    assert_equal 22, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 11 months contract at contract end" do
    @end_date = end_date(@start_date, 11.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date)
    assert_equal 22, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 11 months contract after contract end" do
    @end_date = end_date(@start_date, 11.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date + 2.month)
    assert_equal 22, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 12 months contract before contract end" do
    @end_date = end_date(@start_date, 12.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date - 2.month)
    assert_equal 25, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 12 months contract at contract end" do
    @end_date = end_date(@start_date, 12.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date)
    assert_equal 25, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 12 months contract after contract end" do
    @end_date = end_date(@start_date, 12.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date + 2.month)
    assert_equal 25, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 18 months contract before contract end" do
    @end_date = end_date(@start_date, 18.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date - 2.month)
    assert_equal 25+12, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 18 months contract at contract end" do
    @end_date = end_date(@start_date, 18.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date)
    assert_equal 25+12, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 18 months contract after contract end" do
    @end_date = end_date(@start_date, 18.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date + 2.month)
    assert_equal 25+12, obtained_leave_days
  end

  test "calculate obtained leave days with contract end date for 18 months contract at end of first year" do
    @end_date = end_date(@start_date, 18.month)
    obtained_leave_days = calculate_obtained_leave_days_for_dates_with_contract_end(@start_date, @end_date, @end_date - 6.month)
    assert_equal 25, obtained_leave_days
  end


end
