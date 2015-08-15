class LeaveDayPeriod

  def initialize(start_date)
    @start_date = start_date
    @end_date = start_date
  end

  def start_date
    @start_date
  end

  def end_date
    @end_date
  end

  def end_date=(end_date)
    @end_date = end_date
  end

end
