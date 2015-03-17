class WorkingDay

  def initialize(date)
    @date = date
    @time_entries = []
    @expected_duration = 0
    @default_duration = 0
    @duration = nil
    @working_day = true
    @pause_duration = nil
    @custom_description = nil
    @leave_day = nil
    @validation_errors = []
  end

  def add_time_entry(time_entry)
    @time_entries << time_entry
  end

  def date
    @date
  end

  def time_entries
    @time_entries
  end

  def duration=(duration)
    @duration=duration
  end

  def duration
    @duration
  end

  def expected_duration=(expected_duration)
    @expected_duration=expected_duration
  end

  def expected_duration
    @expected_duration
  end

  def default_duration=(default_duration)
    @default_duration=default_duration
  end

  def default_duration
    @default_duration
  end

  def working_day?
    @working_day
  end

  def working_day=(working_day)
    @working_day=working_day
  end

  def pause_duration=(pause_duration)
    @pause_duration=pause_duration
  end

  def pause_duration
    @pause_duration
  end

  def custom_description=(custom_description)
    @custom_description=custom_description
  end

  def custom_description
    @custom_description
  end

  def leave_day=(leave_day)
    @leave_day=leave_day
  end

  def leave_day
    @leave_day
  end

  def validation_errors=(validation_errors)
    @validation_errors=validation_errors
  end

  def validation_errors
    @validation_errors
  end

end
