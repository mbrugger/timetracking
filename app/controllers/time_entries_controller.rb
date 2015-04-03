class TimeEntriesController < ApplicationController
  include ReportsHelper
  include TimeEntriesHelper
  include DurationFormatHelper
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :user
  load_and_authorize_resource :time_entry, through: :user

  def add_breadcrumbs
    super
    @date = prepare_date
    add_breadcrumb("Time entries", user_time_entries_path(@user, date: @date.to_formatted_s(:datepicker_date)))
  end

  def prepare_content
    @date = prepare_date
    @user = current_user if @user.nil?
    public_holidays = PublicHoliday.where(date: @date)
    report_time_entries = @user.time_entries.where(date: @date)
    @time_entries = @user.time_entries.where(date: @date)
    working_days = process_working_days(@date, @date, report_time_entries, @user.leave_days, @user.employments, public_holidays)
    @working_day = working_days.last
  end


  def day_content
    prepare_content()
    render partial:"day_time_entries", layout:nil, locals:{ display_add_time_entry: true }
  end
  # GET /time_entries
  # GET /time_entries.json
  def index
    prepare_content()
  end

  # GET /time_entries/1
  # GET /time_entries/1.json
  def show
  end

  # GET /time_entries/new
  def new
    @time_entry = @user.time_entries.build
    @time_entry.date = params[:date]
    @time_entry.date = DateTime.now if @time_entry.date.nil?
    add_breadcrumb("New Time entry")
  end

  # GET /time_entries/1/edit
  def edit
    @time_entry = TimeEntry.find(params[:id])
    @user = @time_entry.user
    if !report_for_date(@time_entry.date, @user.reports).nil?
      flash[:alert] = "Can not edit time entries if a report already exists, delete report before editing time entry."
      redirect_to user_time_entries_path(@time_entry.user)
    end
  end

  # POST /time_entries
  # POST /time_entries.json
  def create
    can_create = false
    if can_create_time_entry(params, @user)
      @time_entry = @user.time_entries.create(time_entry_params)
      can_create = true
    else
      flash[:alert] = "Can not create time entries if a report already exists for the given date, delete report before creating time entry."
    end
    respond_to do |format|
      if !@parse_error && can_create && @time_entry.save
        format.html { redirect_to user_time_entries_path(@time_entry.user, date: @time_entry.date), notice: 'Time entry was successfully created.' }
        format.json { render :show, status: :created, location: @time_entry }
      else
        format.html { render :new }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /time_entries/1
  # PATCH/PUT /time_entries/1.json
  def update
    @time_entry = TimeEntry.find(params[:id])

    can_update = false
    if (report_for_date(@time_entry.date, @user.reports).nil? && can_create_time_entry(params, @user))
      can_update = true
    else
      flash[:alert] = "Can not edit time entries if a report already exists, delete report before editing time entry."
    end

    respond_to do |format|
      if !@parse_error && can_update && @time_entry.update(time_entry_params)
        format.html { redirect_to user_time_entries_path(@time_entry.user, date: @time_entry.date), notice: 'Time entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @time_entry }
      else
        format.html { render :edit }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_entries/1
  # DELETE /time_entries/1.json
  def destroy
    can_destroy = false
    if report_for_date(@time_entry.date, @time_entry.user.reports).nil?
      @time_entry.destroy
      can_destroy = true
    end
    respond_to do |format|
      if can_destroy
        format.html { redirect_to user_time_entries_path(@time_entry.user), notice: 'Time entry was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to user_time_entries_path(@time_entry.user), alert: 'Can not destroy time entries if a report already exists, delete report before destroying time entry.' }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_entry
      @time_entry = TimeEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_entry_params
      @parse_error = false
      time_entry = params[:time_entry]

      offset = Time.zone.formatted_offset
      if !time_entry[:start_time_string].nil?
        begin
          if time_entry[:start_time_string].length>0
            start_time = Time.zone.parse(time_entry[:date] + " " + time_entry[:start_time_string])
            time_entry[:startTime] = start_time
          else
            time_entry[:startTime] = nil
          end
          time_entry.delete(:start_time_string)
        rescue  ArgumentError
          flash[:alert] = "Invalid start time #{time_entry[:start_time_string]}"
          @parse_error = true
        end
      end


      if !time_entry[:stop_time_string].nil?
        begin
          if time_entry[:stop_time_string].length>0
            stop_time = Time.zone.parse(time_entry[:date] + " " + time_entry[:stop_time_string])
            time_entry[:stopTime] = stop_time
          else
            time_entry[:stopTime] = nil
          end
          time_entry.delete(:stop_time_string)
        rescue  ArgumentError
          flash[:alert] = "Invalid stop time #{time_entry[:stop_time_string]}"
          @parse_error = true
        end
      end
      params.require(:time_entry).permit(:date, :startTime, :stopTime)
    end
end
