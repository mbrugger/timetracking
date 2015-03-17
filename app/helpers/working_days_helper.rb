module WorkingDaysHelper
  
  def calculate_single_day_working_hours(time_entries)
    working_seconds = 0
    for time_entry in time_entries
      working_seconds += time_entry.duration unless time_entry.duration.nil?
    end
    return working_seconds
  end

  def calculate_single_day_pause_hours(time_entries)
    pause_total = 0
    sorted_time_entries = time_entries.sort {|a,b| a.startTime<=>b.startTime}
    last_time_entry = sorted_time_entries.first
    for time_entry in sorted_time_entries
      pause = time_entry.startTime - last_time_entry.stopTime unless last_time_entry.stopTime.nil?
      pause_total += pause if !pause.nil? && pause > 0
      last_time_entry = time_entry
    end
    return pause_total
  end

end
