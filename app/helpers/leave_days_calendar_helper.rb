module LeaveDaysCalendarHelper

    def aggregate_leave_day_periods(leave_days)
      leave_day_periods = []
      if leave_days.size > 0
        leave_day_period = nil
        for leave_day in leave_days do
          if !leave_day_period.nil? && leave_day_period.end_date+1.day == leave_day.date
            leave_day_period.end_date = leave_day.date
          else
            leave_day_period = LeaveDayPeriod.new(leave_day.date)
            leave_day_periods << leave_day_period
          end
        end
      end
      return leave_day_periods
    end
end
