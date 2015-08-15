class Api::V1::ApiCalendarsController < Api::V1::ApiApplicationController
  include LeaveDaysCalendarHelper
  require 'icalendar/tzinfo'

  def get_auth_token
    return params[:API_AUTH_TOKEN]
  end

  def leave_days
    cal = Icalendar::Calendar.new
    # todo check authentication/authorization
    # add all user leave days

    # event_start = DateTime.new 2015, 8, 1, 8, 0, 0
    # event_end = DateTime.new 2015, 8, 1, 11, 0, 0
    # tzid = "Europe/Vienna"
    # tz = TZInfo::Timezone.get tzid
    # timezone = tz.ical_timezone event_start
    # cal.add_timezone timezone

    for user in User.all do

      leave_day_periods = aggregate_leave_day_periods(user.leave_days)
      
      for leave_day_period in leave_day_periods do
        cal.event do |e|
          e.dtstart = Icalendar::Values::Date.new leave_day_period.start_date
          e.dtstart.ical_params = { "VALUE" => "DATE" }
          e.dtend = Icalendar::Values::Date.new  leave_day_period.end_date
          e.dtend.ical_params = { "VALUE" => "DATE" }

          e.summary = user.visible_name
        end
      end
    end
    respond_to do |format|
      format.ics { send_data(cal.to_ical, :filename=>"leave_days.ics", :disposition=>"inline; filename=leave_days.ics", :type=>"text/calendar")}
    end

  end
end
