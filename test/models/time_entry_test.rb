require 'test_helper'

class TimeEntryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "calculate duration for todays entry without stop time" do
    time_entry = time_entries(:te_today_open)
    expected_duration = (Time.zone.now - time_entry.startTime).to_i
    assert_duration(expected_duration, time_entry.duration)
  end

  test "calculate duration for yesterdays entry without stop time" do
    time_entry = time_entries(:te_yesterday_open)
    assert time_entry.duration == nil
  end

  test "calculate duration for yesterdays entry with stop time" do
    time_entry = time_entries(:te_yesterday)
    assert_duration(8*3600 + 30*60, time_entry.duration)
  end

  test "calculate duration for todays entry with stop time" do
    time_entry = time_entries(:te_today)
    assert_duration(8*3600 + 30*60,time_entry.duration)
  end

  test "calculated duration for template date should be correct" do
    time_entry = time_entries(:closed)
    assert_duration(7200, time_entry.duration)
  end

  test "validation should fail if stop time before start time" do
    time_entry = TimeEntry.new
    time_entry.date = Date.today
    time_entry.startTime = DateTime.now - 10.minutes
    time_entry.stopTime = DateTime.now - 20.minutes
    assert time_entry.valid? == false, "validation should fail for start time > stop time"
  end

end
