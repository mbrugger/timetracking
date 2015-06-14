#
# config/initializers/scheduler.rb

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

s.cron '30 1 * * *' do
  Rails.logger.info "Running working day validation at #{Time.now}"
  WorkingDayValidationController.validate_previous_working_day
end

s.cron '30 1 * * 5' do
  Rails.logger.info "Running working week validation at #{Time.now}"
  WorkingDayValidationController.validate_previous_week
end

s.cron '30 1 1 * *' do
  Rails.logger.info "Running working month validation at #{Time.now}"
  WorkingDayValidationController.validate_previous_month
end
