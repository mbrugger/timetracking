class ReportSummary

  def initialize()
    @expected_working_hours = 0
    @working_hours = 0
    @working_hours_balance = 0
    @total_working_hours_balance = 0
    @leave_days_balance = 0
    @validation_errors = false
    @comp_time = 0
  end

  def expected_working_hours
    @expected_working_hours
  end

  def expected_working_hours=(expected_working_hours)
    @expected_working_hours=expected_working_hours
  end

  def working_hours
    @working_hours
  end

  def working_hours=(working_hours)
    @working_hours = working_hours
  end

  # The working hours balance for the current report
  def working_hours_balance
    @working_hours_balance
  end

  def working_hours_balance=(working_hours_balance)
    @working_hours_balance = working_hours_balance
  end

  # The working hours balance since employment start
  def total_working_hours_balance
    @total_working_hours_balance
  end

  def total_working_hours_balance=(total_working_hours_balance)
    @total_working_hours_balance = total_working_hours_balance
  end

  def previous_working_hours_balance
    @previous_working_hours_balance
  end

  def previous_working_hours_balance=(previous_working_hours_balance)
    @previous_working_hours_balance = previous_working_hours_balance
  end

  def validation_errors?
    @validation_errors
  end

  def validation_errors=(validation_errors)
    @validation_errors = validation_errors
  end

  def comp_time
    @comp_time
  end

  def comp_time=(comp_time)
    @comp_time = comp_time
  end

end
