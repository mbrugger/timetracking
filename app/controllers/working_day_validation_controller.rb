class WorkingDayValidationController
  include ReportsValidationHelper
  include ReportsHelper

  @@instance = WorkingDayValidationController.new

  def self.instance
    return @@instance
  end

  def self.validate_previous_working_day
    validation_day = Date.today-1
    self.instance.validate_working_day(validation_day)
  end

  def self.validate_previous_week
    start_date = (Date.today - 7.days).at_beginning_of_week
    end_date = (Date.today - 7.days).at_end_of_week
    self.instance.validate_working_days_for_duration(start_date, end_date)
  end

  def self.validate_previous_month
    start_date = (Date.today - 1.month).at_beginning_of_month
    end_date = (Date.today - 1.month).at_end_of_month
    self.instance.validate_working_days_for_duration(start_date, end_date)
  end

  def validate_working_day(validation_day)
    Rails.logger.info "running working day validation for #{validation_day}"
    public_holidays = PublicHoliday.where(date: validation_day)

    for user in User.all do
      Rails.logger.info "Validating working day for #{user.email}"
      time_entries = user.time_entries.where(date: validation_day)
      working_days = process_working_days(validation_day, validation_day, time_entries, user.leave_days, user.employments, public_holidays)
      validation_errors = working_days.first.validation_errors
      if validation_errors.size > 0
        Rails.logger.info "Sending validation failed message to user #{user.email}"
        UserMailer.notify_working_day_validation_error(user, working_days.first, validation_errors).deliver
      end
    end
    return
  end

  def validate_working_days_for_duration(start_date, end_date)
    Rails.logger.info "running working day validation from #{start_date} to #{end_date}"
    validation_range = start_date..end_date
    public_holidays = PublicHoliday.where(date: validation_range).order('date ASC')
    #Rails.logger.info "public_holidays #{public_holidays}"
    for user in User.all do
      Rails.logger.info "Validating user #{user.email}"
      leave_days = user.leave_days.where(date: validation_range)
      #Rails.logger.info "leave_days #{leave_days}"
      time_entries = user.time_entries.where(date: validation_range).order('date ASC')
      #Rails.logger.info "time_entries #{time_entries}"
      working_days = process_working_days(start_date, end_date, time_entries, leave_days, user.employments, public_holidays)
      has_validation_errors = false
      failed_days = []
      for working_day in working_days do
        if working_day.validation_errors.size>0
          failed_days << working_day
        end
      end

      if failed_days.size > 0
        Rails.logger.info "Sending validation failed message to user #{user.email}"
        UserMailer.notify_validation_error(user, start_date, end_date, failed_days).deliver
      end
    end
    return nil
  end

end
