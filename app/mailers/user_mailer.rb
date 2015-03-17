class UserMailer < ActionMailer::Base
  default from: "noreply@bytepoets.com"
  helper :duration_format
  include DurationFormatHelper

  def notify_working_day_validation_error(user, working_day, validation_errors)
    @user = user
    @url = user_time_entries_url(@user)
    @working_day = working_day
    @validation_errors = validation_errors
    mail(to: @user.email, subject: "Time tracking validation failed on #{working_day.date.to_formatted_s(:pretty_date)}")
  end

  def notify_validation_error(user, start_date, end_date, working_days)
    @user = user
    @url = user_time_entries_url(@user)
    @working_days = working_days
    @start_date = start_date
    @end_date = end_date
    mail(to: @user.email, subject: "Time tracking validation failed")
  end

  def notify_account_created(user, url)
    @user = user
    @url = url
    mail(to: @user.email, subject: "Time tracking account created")
  end
end
