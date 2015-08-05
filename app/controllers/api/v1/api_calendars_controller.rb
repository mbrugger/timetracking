class Api::V1::ApiCalendarsController < Api::V1::ApiApplicationController
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

      for leave_day in user.leave_days do
        cal.event do |e|
          e.dtstart = Icalendar::Values::Date.new leave_day.date
          e.dtstart.ical_params = { "VALUE" => "DATE" }
          e.dtend = Icalendar::Values::Date.new  leave_day.date
          e.dtend.ical_params = { "VALUE" => "DATE" }

          e.summary = user.visible_name
          e.description = leave_day.localized_leave_day_type
        end
      end
    end


    respond_to do |format|
      format.ics { send_data(cal.to_ical, :filename=>"leave_days.ics", :disposition=>"inline; filename=leave_days.ics", :type=>"text/calendar")}
    end

  end
end
