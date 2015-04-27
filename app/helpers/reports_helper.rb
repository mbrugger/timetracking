module ReportsHelper
  include EmploymentsHelper
  include DurationFormatHelper
  include ReportsValidationHelper
  include WorkingDaysHelper

  def prepare_date(date_string)
    if !date_string.nil?
      return Date.parse(date_string)
    end
    return nil
  end

  def process_working_days(start_date, end_date, time_entries, leave_days, employments, public_holidays, validate_missing_time_entries = true)
    working_days = []
    working_days_with_time_entries = prepare_working_days_for_time_entries(time_entries)
    for date in start_date..end_date
      working_day = working_days_with_time_entries[date]
      if working_day.nil?
        working_day = WorkingDay.new(date)
      end
      evaluate_working_day_status(working_day, public_holidays, leave_days)
      process_working_day(working_day, leave_days, public_holidays, employments, validate_missing_time_entries)
      working_days<<working_day
    end
    return working_days
  end

  def prepare_working_days_for_time_entries(time_entries)
    working_days_hash = {};
    for time_entry in time_entries
      if working_days_hash[time_entry.date]
        working_days_hash[time_entry.date].add_time_entry(time_entry)
      else
        working_day = WorkingDay.new(time_entry.date)
        working_day.add_time_entry(time_entry)
        working_days_hash[time_entry.date] = working_day
      end
    end
    return working_days_hash
  end

  def process_working_day(working_day, leave_days, public_holidays, employments, validate_missing_time_entries = true)
    working_day.duration = calculate_single_day_working_hours(working_day.time_entries)
    working_day.default_duration = calculate_working_day_default_hours(working_day, employments)
    working_day.expected_duration = calculate_working_day_expected_hours(working_day, leave_days, public_holidays, employments)
    working_day.pause_duration = calculate_single_day_pause_hours(working_day.time_entries)
    working_day.custom_description = calculate_single_day_custom_description(working_day, leave_days, public_holidays)

    minimum_pause = 30.minutes
    if working_day.duration >= 6.hours and working_day.pause_duration < minimum_pause
      missing_pause = minimum_pause - working_day.pause_duration
      working_day.duration -= missing_pause
      working_day.pause_duration += missing_pause
    end
    # validate time entries and display errors/warnings
    working_day.validation_errors = calculate_single_day_validation_errors(working_day, validate_missing_time_entries)
    return working_day
  end

  def calculate_single_day_custom_description(working_day, leave_days, public_holidays)
    holiday = (public_holidays.select {|day| day.date == working_day.date}).first
    if !holiday.nil?
      return holiday.name
    end
  end

  def evaluate_working_day_status(working_day, public_holidays, leave_days)
    #logger.debug "evaluating working day status for #{working_day.date}"
    is_holiday = (public_holidays.select {|day| day.date == working_day.date}).size > 0
    leave_day = (leave_days.select {|day| day.date == working_day.date}).first
    is_leave_day = !leave_day.nil?
    working_day.leave_day = leave_day
    working_day.working_day=!(working_day.date.saturday? || working_day.date.sunday? || is_holiday || is_leave_day)
    #logger.debug "status = #{working_day.working_day?}"
  end

  def calculate_working_day_expected_hours(working_day, leave_days, public_holidays, employments)
    result = 0
    employment = employment_for_date(working_day.date, employments)
    if working_day.working_day? && !employment.nil?
      result = employment.weeklyHours/5*60*60
    end
    return result
  end

  def calculate_working_day_default_hours(working_day, employments)
    result = 0
    employment = employment_for_date(working_day.date, employments)
    if !employment.nil?
      result = employment.weeklyHours/5*60*60
    end
    return result
  end

  def calculate_expected_working_hours(working_days)
    result = 0;
    for working_day in working_days
      result += working_day.expected_duration
    end
    result
  end

  def calculate_working_hours(working_days)
    result = 0;
    for working_day in working_days
      result += working_day.duration
    end
    result
  end

  def calculate_comp_time(working_days)
    result = 0;
    for working_day in working_days
      #puts "comp time calc: #{working_day.inspect}"
      if !working_day.leave_day.nil? && working_day.leave_day.leave_day_type == 'comp_time'
        result += working_day.default_duration
      end
    end
    result
  end

  def report_for_date(date, reports)
    report_date = Date.new(date.year, date.month, 1)
    return (reports.select {|report| report.date == report_date}).first
  end
end
