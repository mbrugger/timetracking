module ReportsValidationHelper

  include WorkingDaysHelper

  def calculate_single_day_validation_errors(working_day, validate_missing_time_entries = true)
    result = []
    time_entries = sorted_time_entries(working_day.time_entries)
    validate_overlapping_time_entries(time_entries, result)
    #validate negative time entry duration?
    validate_negative_duration(time_entries, result)
    #validate working time <10h
    validate_duration(working_day, result)
    #validate start >= 6:00 && stop <=22:00
    validate_start_time(time_entries, result) if time_entries.size > 0
    validate_stop_time(time_entries, result) if time_entries.size > 0
    #validate missing stopTime (only not today)
    validate_missing_stop_time(time_entries, result)
    #print "\n validate #{working_day.inspect} missing time entries: #{validate_missing_time_entries}\n"
    if validate_missing_time_entries
      validate_missing_time_entries(working_day, result)
    end
    return result
  end

  def validate_overlapping_time_entries(time_entries, result)
    previous_stop_time = nil
    for time_entry in time_entries
      if previous_stop_time == nil
        previous_stop_time = time_entry.stopTime
      elsif time_entry.startTime < previous_stop_time
        result << I18n.t('helpers.reports_validation.overlapping_time_entries')
        break
      end
    end
  end

  def validate_negative_duration(time_entries, result)
    for time_entry in time_entries
      if !time_entry.duration.nil? && time_entry.duration < 0
        result << I18n.t('helpers.reports_validation.invalid_duration')
        break
      end
    end
  end

  def validate_duration(working_day, result)
    working_day.duration = calculate_single_day_working_hours(working_day.time_entries) if working_day.duration.nil?
    if working_day.duration > 10.hours
      result << I18n.t('helpers.reports_validation.duration_exceeding_daily_limit')
    end
  end

  def validate_start_time(time_entries, result)
    entry_date = time_entries.first.date
    working_day_start = Time.zone.now.change({year: entry_date.year, month: entry_date.month, day:entry_date.day, hour: 6, min: 0, sec: 0})
    if (time_entries.first.startTime < working_day_start )
      result << I18n.t('helpers.reports_validation.invalid_start_time')
    end
  end

  def validate_stop_time(time_entries, result)
    working_day_end = time_entries.last.date.to_datetime
    entry_date = time_entries.first.date
    working_day_end = Time.zone.now.change({year: entry_date.year, month: entry_date.month, day:entry_date.day, hour: 22, min: 0, sec: 0})
    if (!time_entries.last.stopTime.nil? && time_entries.last.stopTime > working_day_end )
      result << I18n.t('helpers.reports_validation.invalid_stop_time')
    end
  end

  def validate_missing_stop_time(time_entries, result)
    for time_entry in time_entries
      if time_entry.date != Date.today and time_entry.stopTime.nil?
        result << I18n.t('helpers.reports_validation.missing_stop_time')
        break
      end
    end
  end

  def validate_missing_time_entries(working_day, result)
    if working_day.expected_duration > 0
      if working_day.date < Date.today && (working_day.time_entries.nil? || working_day.time_entries.size == 0)
        result << I18n.t('helpers.reports_validation.missing_time_entries')
      end
    end
  end

  def sorted_time_entries(time_entries)
    time_entries.sort {|a,b| a.startTime<=>b.startTime}
  end

end
