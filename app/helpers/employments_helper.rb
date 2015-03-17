module EmploymentsHelper

  def sort_employments(employments)
    employments.sort {|a,b| a.startDate <=> b.startDate}
  end

  def filter_employments(start_date, end_date, employments)
    result = []
    for employment in employments
      if employment_relevant(start_date, end_date, employment)
        result << employment
      end
    end
    return sort_employments(result)
  end

  def employment_for_date(date, employments)
    for employment in employments
        if employment_relevant(date, date, employment)
          return employment
        end
      end
    return nil;
  end

  # find latest employment by start date
  def find_latest_employment_start(employments)
    # sort latest to oldes
    employments = employments.sort {|a,b| b.startDate <=> a.startDate}
    return employments.first
  end

private
  def employment_relevant(start_date, end_date, employment)
    #puts "checking start_date: #{start_date}, end_date: #{end_date} employment: #{employment.startDate} - #{employment.endDate}"
    employment_relevant = employment.startDate <= start_date && (employment.endDate.nil? || employment.endDate >= start_date)
    employment_relevant ||= employment.startDate >= start_date && employment.startDate <= end_date
    employment_relevant ||= employment.startDate <= end_date && (employment.endDate.nil? || employment.endDate >= end_date)
    return employment_relevant
  end
end
