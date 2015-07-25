class StatisticsController < ApplicationController
  include LeaveDaysHelper
  include ReportsHelper
  include ReportSummariesHelper

  def index
    authorize! :statistics, :index
  end

  def working_hours
    authorize! :statistics, :working_hours
    add_breadcrumb(I18n.t('controllers.statistics.breadcrumbs.working_hours'))
    prepare_working_hours_content
  end

  def leave_days
    authorize! :statistics, :leave_days
    @date = Date.today
    add_breadcrumb(I18n.t('controllers.statistics.breadcrumbs.leave_days'))
    prepare_leave_days_content
  end

  def add_breadcrumbs
    super
    add_breadcrumb(I18n.t('controllers.statistics.breadcrumbs.statistics'), statistics_index_path)
  end

  def prepare_date
    if !params[:date].nil?
      return Date.parse(params[:date])
    end
    return Date.today
  end

  def leave_days_content
    authorize! :statistics, :leave_days
    prepare_leave_days_content
    render partial:"leave_days_content", layout:nil
  end

  def working_hours_content
    authorize! :statistics, :working_hours
    prepare_working_hours_content
    render partial:"working_hours_content", layout:nil
  end

  def prepare_leave_days_content
    @date = prepare_date
    @user_leave_days_statistic = []
    @total_leave_days = 0

    for user in User.all do
      employment_at_date = employment_for_date(@date, user.employments)
      if !employment_at_date.nil?
        user_statistic = {user: user}
        @user_leave_days_statistic << user_statistic
        begin
          if !employment_at_date.migrated_employment
            leave_days_available = calculate_available_leave_days(@date, user.employments, user.leave_days)
            user_statistic[:leave_days_available] = leave_days_available
            @total_leave_days += leave_days_available
          end
        rescue ArgumentError
          log.info "no employment available for statistics date"
          user_statistic[:error] = "Error retrieving user leave days statistic"
        end
      end
    end
  end

  def prepare_working_hours_content
    @start_date = Date.parse(params[:start_date]) unless params[:start_date].nil?
    @end_date = Date.parse(params[:end_date]) unless params[:end_date].nil?

    @start_date = Date.today.beginning_of_month if @start_date.nil?
    @end_date = Date.today.end_of_month if @end_date.nil?

    @user_working_hours_statistic = []
    @total_working_hours_planned = 0
    @total_working_hours_actual = 0

    public_holidays = PublicHoliday.where(date: @start_date..@end_date)

    for user in User.all do

      working_days = process_working_days(@start_date,
                                            @end_date,
                                            user.time_entries,
                                            user.leave_days,
                                            user.employments,
                                            public_holidays,
                                            user.validate_working_days)
      if (working_days.count > 0)
          current_user_working_hours_statistic = {user: user}
          @user_working_hours_statistic << current_user_working_hours_statistic
          report_summary = create_report_summary(working_days, user.employments, user.reports)
          current_user_working_hours_statistic[:working_hours_planned] = report_summary.expected_working_hours
          current_user_working_hours_statistic[:working_hours_actual] = report_summary.working_hours
          @total_working_hours_planned += report_summary.expected_working_hours
          @total_working_hours_actual += report_summary.working_hours
      end

    end
  end

end
