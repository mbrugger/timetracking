module HomeHelper
  include ReportsHelper
  include ReportSummariesHelper
  def prepare_current_status
    start_date = Date.today.beginning_of_month
    end_date = Date.today
    public_holidays = PublicHoliday.where(date: start_date..end_date)
    report_time_entries = @user.time_entries.where(date: start_date..end_date)
    @timer_running = @user.time_entries.where(date: Date.today, stopTime: nil).size > 0
    @time_entries = @user.time_entries.where(date: Date.today)
    working_days = process_working_days(start_date, end_date, report_time_entries, @user.leave_days, @user.employments, public_holidays)
    @working_day = working_days.last
    working_days = working_days[0..-2]
    @report_summary = create_report_summary(working_days, @user.employments, [])
  end
end
