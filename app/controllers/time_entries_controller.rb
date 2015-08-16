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
    add_breadcrumb(I18n.t('controllers.time_entries.breadcrumbs.time_entries'), user_time_entries_path(@user, date: @date.to_formatted_s(:datepicker_date)))
  end

  def prepare_content
    @date = prepare_date
    @user = current_user if @user.nil?
    public_holidays = PublicHoliday.where(date: @date)
    report_time_entries = @user.time_entries.where(date: @date)
    @time_entries = @user.time_entries.where(date: @date)
    working_days = process_working_days(@date, @date, report_time_entries, @user.leave_days, @user.employments, public_holidays, @user.validate_working_days)
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
    add_breadcrumb(I18n.t('controllers.time_entries.breadcrumbs.new_time_entry'))
  end

  # GET /time_entries/1/edit
  def edit
    @time_entry = TimeEntry.find(params[:id])
    @user = @time_entry.user
    if !report_for_date(@time_entry.date, @user.reports).nil?
      flash[:alert] = I18n.t('controllers.time_entries.error_edit_report_already_exists')
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
      flash[:alert] = I18n.t('controllers.time_entries.error_create_report_already_exists')
    end
    respond_to do |format|
      if !@parse_error && can_create && @time_entry.save
        format.html { redirect_to user_time_entries_path(@time_entry.user, date: @time_entry.date), notice: I18n.t('controllers.time_entries.successfully_created') }
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
      flash[:alert] = I18n.t('controllers.time_entries.error_edit_report_already_exists')
    end

    respond_to do |format|
      if !@parse_error && can_update && @time_entry.update(time_entry_params)
        format.html { redirect_to user_time_entries_path(@time_entry.user, date: @time_entry.date), notice: I18n.t('controllers.time_entries.successfully_updated') }
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
        format.html { redirect_to user_time_entries_path(@time_entry.user), notice: I18n.t('controllers.time_entries.successfully_destroyed') }
        format.json { head :no_content }
      else
        format.html { redirect_to user_time_entries_path(@time_entry.user), alert: I18n.t('controllers.time_entries.error_delete_report_already_exists') }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_entry
      @time_entry = TimeEntry.find(params[:id])
    end

    def parse_time_parameter(time_entry, parameter_string_field, parameter_field, error_key)
      parameter_string_value = time_entry[parameter_string_field]
      if !parameter_string_value.nil?
        begin
          if parameter_string_value.length>0
            parsed_time = Time.zone.parse(time_entry[:date] + " " + parameter_string_value)
            time_entry[parameter_field] = parsed_time
          else
            time_entry[parameter_field] = nil
          end
          time_entry.delete(parameter_string_field)
        rescue  ArgumentError
          flash[:alert] = I18n.t(error_key, parameter_string_value: parameter_string_value)
          @parse_error = true
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_entry_params
      @parse_error = false
      time_entry = params[:time_entry]

      parse_time_parameter(time_entry, 'start_time_string', 'startTime', 'controllers.time_entries.error_invalid_start_time')
      parse_time_parameter(time_entry, 'stop_time_string', 'stopTime', 'controllers.time_entries.error_invalid_stop_time')
      params.require(:time_entry).permit(:date, :startTime, :stopTime)
    end
end
