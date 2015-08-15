class Api::V1::ApiCalendarsController < Api::V1::ApiApplicationController
  include LeaveDaysCalendarHelper
  require 'icalendar/tzinfo'

  def get_auth_token
    return params[:API_AUTH_TOKEN]
  end

  def leave_days
    cal = Icalendar::Calendar.new
    for user in User.all do

      leave_day_periods = aggregate_leave_day_periods(user.leave_days)
      for leave_day_period in leave_day_periods do
        create_all_day_event(cal, leave_day_period.start_date, leave_day_period.end_date, user.visible_name)
      end
    end
    respond_to do |format|
      format.ics { send_data(cal.to_ical, :filename=>"leave_days.ics", :disposition=>"inline; filename=leave_days.ics", :type=>"text/calendar")}
    end
  end

  def public_holidays
    cal = Icalendar::Calendar.new
    for public_holiday in PublicHoliday.all do
      create_all_day_event(cal, public_holiday.date, public_holiday.date, public_holiday.name)
    end
    respond_to do |format|
      format.ics { send_data(cal.to_ical, :filename=>"public_holidays.ics", :disposition=>"inline; filename=public_holidays.ics", :type=>"text/calendar")}
    end
  end

  def create_all_day_event(calendar, start_date, end_date, summary)
    calendar.event do |e|
      e.dtstart = Icalendar::Values::Date.new start_date
      e.dtstart.ical_params = { "VALUE" => "DATE" }
      e.dtend = Icalendar::Values::Date.new  end_date
      e.dtend.ical_params = { "VALUE" => "DATE" }
      e.summary = summary
    end
  end

end
