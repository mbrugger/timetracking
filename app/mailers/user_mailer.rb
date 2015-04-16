class UserMailer < ActionMailer::Base
  default from: ENV['MAIL_FROM']
  helper :duration_format
  include DurationFormatHelper

  def notify_working_day_validation_error(user, working_day, validation_errors)
    @user = user
    @url = user_time_entries_url(@user, locale: I18n.default_locale)
    @working_day = working_day
    @validation_errors = validation_errors
    mail(to: @user.email, subject: I18n.t('mailers.user_mailer.validation_failed_on_date', date: working_day.date.to_formatted_s(:pretty_date)))
  end

  def notify_validation_error(user, start_date, end_date, working_days)
    @user = user
    @url = user_time_entries_url(@user, locale: I18n.default_locale)
    @working_days = working_days
    @start_date = start_date
    @end_date = end_date
    mail(to: @user.email, subject: I18n.t('mailers.user_mailer.validation_failed'))
  end

  def notify_account_created(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: I18n.t('mailers.user_mailer.account_created_notification_subject'))
  end
end
