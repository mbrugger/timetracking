require 'test_helper'

class TimeTrackingControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    @current_user = users(:time_tracking_user)
    sign_in @current_user
    # puts "signed in: #{@current_user.id}\n"
    # puts "time entries in user sign in: #{@current_user.time_entries.size}\n"
  end

  test "start should create correct time entry" do
    post :start
    assert_response :found
    user = User.find(@current_user.id)
    created_entry = user.time_entries.first
    # puts "user after start called: #{user.id}\n"
    # puts "time entries in user after start: #{user.time_entries.size}\n"
    # puts "created entry: #{created_entry.inspect}\n"
    assert created_entry.date == Date.today, "#{created_entry.date}"
    assert created_entry.stopTime.nil?
    assert !created_entry.startTime.nil?
  end

  test "stop should create correct time entry" do
    post :start
    user = User.find(@current_user.id)
    assert user.time_entries.size == 1, "entries: #{user.time_entries.inspect}"
    post :stop
    assert_response :found
    user = User.find(@current_user.id)
    created_entry = user.time_entries.first
    assert !created_entry.stopTime.nil?
    assert !created_entry.startTime.nil?
  end

  test "do not allow start time tracking if report already has been created" do
    report = Report.new
    report.date = Date.new(Date.today.year, Date.today.month, 1)
    report.user_id = @current_user.id
    report.balance = 1.hour
    assert report.save, 'Could not create report for testing'

    assert_no_difference('TimeEntry.count') do
      post :start
    end
  end

end
