module TimeEntriesHelper

  def can_create_time_entry(unprocessed_params, user)
    time_entry = unprocessed_params[:time_entry]
    date = Date.parse(time_entry[:date])
    if report_for_date(date, user.reports).nil?
      return true
    end
    return false
  end

  def prepare_date
    if !params[:date].nil?
      return Date.parse(params[:date])
    end
    return Date.today
  end

end
