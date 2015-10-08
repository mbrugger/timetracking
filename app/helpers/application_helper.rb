module ApplicationHelper

  def parse_duration(duration_string)
    duration = duration_string
    duration_components = duration_string.split(":")
    if duration_components.size == 2
      hours = duration_components[0].to_i
      minutes = duration_components[1].to_i
      if duration_components[0].strip.starts_with?('-')
        minutes *= -1
      end
      duration = hours.hours + minutes.minutes
    end
    return duration
  end

end
