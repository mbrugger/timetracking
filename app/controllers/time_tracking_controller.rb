class TimeTrackingController < ApplicationController
  include ReportsHelper
  skip_authorization_check

  def start
    user = current_user
    can_start = false
    error_details = ''
    if report_for_date(Date.today, user.reports).nil?
      can_start = true
      @time_entry = user.time_entries.create(date: Date.today, startTime: DateTime.now.change(:sec => 0))
    else
      error_details = ' A report has already been created for the current month.'
    end

    respond_to do |format|
      if can_start && @time_entry.save
        format.html { redirect_to locale_root_path, notice: 'Time tracking was successfully started.' }
        format.json { render :show, status: :created, location: @time_entry }
      else
        format.html { redirect_to locale_root_path, alert: 'Time tracking could not be started!'+error_details }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def stop
    user = current_user
    @time_entry = user.time_entries.where(date: Date.today, stopTime: nil).first
    @time_entry.stopTime = DateTime.now.change(:sec => 0)
    respond_to do |format|
      if @time_entry.save
        format.html { redirect_to locale_root_path, notice: 'Time tracking was successfully stopped.' }
        format.json { render :show, status: :ok, location: @time_entry }
      else
        format.html { redirect_to locale_root_path, alert: 'Time tracking could not be stopped!' }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

end
