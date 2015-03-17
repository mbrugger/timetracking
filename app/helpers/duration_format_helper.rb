module DurationFormatHelper

  def format_duration_null(duration)
    format_duration = duration
    if duration.nil?
      format_duration = 0
    end
    hours = (duration.abs / 3600).floor
    minutes = ((duration.abs - hours * 3600.0)/60.0).floor
    sign = ""
    sign = "-" if duration < 0
    return "#{sign}#{hours}:#{minutes.to_s.rjust(2, '0')}"
  end

  def format_duration(duration)
    if duration.nil? || duration == 0
      return ""
    end
    return format_duration_null(duration)
  end
end
