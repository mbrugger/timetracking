class StatisticsController < ApplicationController
  include LeaveDaysHelper

  def index
    authorize! :statistics, :index
  end

  def working_hours
    authorize! :statistics, :working_hours
    add_breadcrumb(I18n.t('controllers.statistics.breadcrumbs.working_hours'))
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
            logger.info "#{user.name} has #{leave_days_available} at requested date #{@date.to_formatted_s(:datepicker_date)}"
          end
        rescue ArgumentError
          log.info "no employment available for statistics date"
            user_statistic[:error] = "Error retrieving user leave days statistic"
        end
      end
    end
  end
end
