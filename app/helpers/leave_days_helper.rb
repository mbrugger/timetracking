module LeaveDaysHelper
  include EmploymentsHelper

  def calculate_available_leave_days(date, employments, leave_days)
    #print "calculate available leave days for date: #{date} \n"
    obtained_leave_days = calculate_obtained_leave_days(date, employments)
    consumed_leave_days = (leave_days.select {|leave_day| leave_day.date <= date && leave_day.leave_day_type == "leave_day"}).size
    #print "consumed_leave_days: #{consumed_leave_days}\n"
    return obtained_leave_days - consumed_leave_days
  end

  def calculate_obtained_leave_days(date, employments)
    sorted_employments = employments.sort {|a,b| a.startDate <=> b.startDate}
    if !sorted_employments.last.endDate.nil? && date > sorted_employments.last.endDate
      date = sorted_employments.last.endDate
    end

    first_employment = sorted_employments.first

    contract_start_date = sorted_employments.first.startDate
    contract_end_date = sorted_employments.last.endDate


    if (first_employment.migrated_employment? && date <= first_employment.endDate)
      raise ArgumentError, "Leave days calculation not support in migrated employment"
    end
    if first_employment.migrated_employment? && contract_start_date < (first_employment.endDate - 1.year)
      #print "mig calculation\n"
      obtained_leave_days_before_migration = calculate_obtained_leave_days_for_dates(contract_start_date, first_employment.endDate)
      obtained_leave_days = calculate_obtained_leave_days_for_dates(contract_start_date, date) - obtained_leave_days_before_migration
      obtained_leave_days += first_employment.leave_days
    else
      #print "standard calculation \n"
      obtained_leave_days = calculate_obtained_leave_days_for_dates(contract_start_date, date)
      #print "obtained: #{obtained_leave_days} from #{sorted_employments.first.startDate} to #{date} \n"
    end

    # if the employment has been terminated, reduce obtained leave days for final working year
    if !contract_end_date.nil? && calculate_employment_months(contract_start_date, contract_end_date) > 6
      final_working_year_start = calculate_working_year_start(contract_end_date, contract_start_date)
      # only consider contract end when calculating leave days in final year of contract
      if date > final_working_year_start
        #print "calculating reduced available leave days because contract is already terminated\n"
        if calculate_employment_months(contract_start_date, contract_end_date) > 6
          employment_months_in_final_year = calculate_employment_months(final_working_year_start, contract_end_date) + 1
          #print "final year employment months: #{employment_months_in_final_year}\n"
          if (employment_months_in_final_year < 12)
            obtained_leave_days_in_final_year = employment_months_in_final_year * 2;
          else
            obtained_leave_days_in_final_year = 25
          end
          leave_days_reduction = 25 - obtained_leave_days_in_final_year
          #print "reducing leave days by #{leave_days_reduction} for early termination\n"
          obtained_leave_days -= leave_days_reduction
        end
      end
    end
    return obtained_leave_days
  end

  def calculate_obtained_leave_days_for_dates(start_date, current_date)
    employed_months = calculate_employment_months(start_date, current_date)
    #print "employment month #{employed_months} \n"
    if employed_months < 6
      # 0-6 months
      return (employed_months+1) * 2
    elsif employed_months < 12
      # 6-12 months
      return 25
    else
      # > 12 months
      employed_years = (employed_months-(employed_months%12))/12
      #print "years: #{employed_years} \n"
      return (employed_years+1) * 25
    end
  end

  def calculate_employment_months(start_date, date)
    #print "start_date: #{start_date} - date: #{date}"
    calendar_months = (date.year * 12 + date.month) - (start_date.year * 12 + start_date.month)-1
    if  date.day >= start_date.day
      #print "day in month #{date.day} >= reference day in month #{start_date.day}"
      calendar_months += 1
    end
    return calendar_months
  end

  def calculate_consumed_leave_days(date, employments, leave_days)
    sorted_employments = employments.sort {|a,b| a.startDate <=> b.startDate}
    working_year_start = calculate_working_year_start(date, sorted_employments.first.startDate)
    return (leave_days.select {|leave_day| leave_day.date <= date && leave_day.date >= working_year_start && leave_day.leave_day_type == "leave_day"}).size
  end

  def calculate_working_year_start(date, employment_start_date)
    working_year = date.year
    if Date.new(working_year, employment_start_date.month, employment_start_date.day) > date
      working_year -= 1
    end
    return Date.new(working_year, employment_start_date.month, employment_start_date.day)
  end
end
