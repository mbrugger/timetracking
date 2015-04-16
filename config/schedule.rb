# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :job_template, "/bin/bash -i -c ':job'"

every 1.day, :at => '1:30 am' do
  runner "WorkingDayValidationController.validate_previous_working_day"
end

every :friday, :at => '1:30am' do
  runner "WorkingDayValidationController.validate_previous_week"
end

every '30 1 1 * *' do
  runner "WorkingDayValidationController.validate_previous_month"
end
