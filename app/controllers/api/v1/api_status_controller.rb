class Api::V1::ApiStatusController < Api::V1::ApiApplicationController
  include HomeHelper

  def status
    @user = api_user
    process_response
  end

  def start
    @user = api_user
    timer_running = !fetch_running_time_entry.nil?
    create_entry_success = false
    if !timer_running
      new_time_entry = @user.time_entries.create(date: Date.today, startTime: DateTime.now.change(:sec => 0))
      create_entry_success = new_time_entry.save
    end

    if timer_running || create_entry_success
      process_response
    else
      render json: { error: "could not save time entry" }, status: :unprocessable_entity
    end
  end

  def stop
    @user = api_user
    time_entry = @user.time_entries.where(date: Date.today, stopTime: nil).first
    save_time_entry_success = false
    if !time_entry.nil?
      time_entry.stopTime = DateTime.now.change(:sec => 0)
      save_time_entry_success = time_entry.save
    end

    if time_entry.nil? || save_time_entry_success
      process_response
    else
      render json: { error: "could not save time entry" }, status: :unprocessable_entity
    end
  end

  def process_response
    prepare_current_status
    duration = format_duration_null(@working_day.duration)
    pause_duration = format_duration_null(@working_day.pause_duration)
    current_status = "stopped"
    if @timer_running
      current_status = "running"
    end
    render json: { status: current_status, duration: duration, pause_duration: pause_duration}
  end

  def fetch_running_time_entry
    time_entry = @user.time_entries.where(date: Date.today, stopTime: nil).first
    return time_entry
  end
end
