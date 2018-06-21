
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include DurationFormatHelper

  def given_authenticated_user(user)
    @current_user = user
    if user.admin?
      @request.env["devise.mapping"] = Devise.mappings[:admin]
    end
    sign_in user
  end

  def create_working_days
    first_working_day = WorkingDay.new(Date.new(2014,12,9))
    first_working_day.expected_duration = 60*60*8
    first_working_day.duration = 60*60*7

    second_working_day = WorkingDay.new(Date.new(2014,12,10))
    second_working_day.expected_duration = 60*60*8
    second_working_day.duration = 60*60*6

    return [first_working_day, second_working_day]
  end

  def assert_duration(expected, actual, message=nil)
    assert_message = "expected: #{format_duration(expected)} got: #{format_duration(actual)}"
    if !message.nil?
      assert_message += " for #{message}"
    end
    assert expected.to_i == actual.to_i, assert_message
  end

  def assert_leave_day(expected_leave_day)
    actual_leave_day = LeaveDay.find(expected_leave_day.id)
    # puts "#{expected_leave_day.inspect} - #{actual_leave_day.inspect}"
    assert_equal expected_leave_day.date, actual_leave_day.date
    assert_equal expected_leave_day.description, actual_leave_day.description
    assert_equal expected_leave_day.leave_day_type, actual_leave_day.leave_day_type
  end
end
