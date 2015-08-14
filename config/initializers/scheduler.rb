#
# config/initializers/scheduler.rb

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton
if ENV['SCHEDULE_VALIDATION_TASKS']

  Rails.logger.info "Activate time tracking validation jobs"

  s.cron '30 1 * * *' do
    Rails.logger.info "Running working day validation at #{Time.now}"
    WorkingDayValidationController.validate_previous_working_day
  end

  s.cron '30 3 * * 1' do
    Rails.logger.info "Running working week validation at #{Time.now}"
    WorkingDayValidationController.validate_previous_week
  end

  s.cron '30 1 1 * *' do
    Rails.logger.info "Running working month validation at #{Time.now}"
    WorkingDayValidationController.validate_previous_month
  end
else
  Rails.logger.info "Do not activate time tracking validation jobs"
end
