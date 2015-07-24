class LeaveDaysController < ApplicationController
  include LeaveDaysHelper
  before_action :set_leave_day, only: [:show, :edit, :update, :destroy]
  before_action :verify_employment

  load_and_authorize_resource :user
  load_and_authorize_resource :leave_day, through: :user

  def prepare_year_filter
    @year = params[:year].to_i
    @year = Date.today.year if @year == 0
  end

  def add_breadcrumbs
    super
    add_breadcrumb(I18n.t('controllers.leave_days.breadcrumbs.leave_days'), user_leave_days_path(@user))
  end

  # GET /user/:user_id/leave_days?year=:year
  # GET /user/:user_id/leave_days.json
  def index
    @year = params[:year].to_i
    if @year == 0
      @year = calculate_working_year_start(Date.today, @user.employments).year
    end

    @working_year_start = calculate_working_year_start(Date.new(@year, 12, 31), @user.employments)
    @working_year_end = calculate_working_year_start(Date.new(@year+1, 12, 31), @user.employments) - 1.day
    begin
    @leave_days = LeaveDay.where(user_id: @user.id, date: (@working_year_start..@working_year_end)).order('date ASC')

    working_year_start_employment = employment_for_date(@working_year_start, @user.employments)
    if working_year_start_employment.nil?
      raise ArgumentError, "Leave days calculation not available prior to employment start"
    end
    @leave_days_consumed = calculate_consumed_leave_days(@working_year_end, @user.employments, @user.leave_days)
    @leave_days_available = calculate_available_leave_days(@working_year_end, @user.employments, @user.leave_days)
    @leave_days_working_year_start = @leave_days_available - @leave_days_consumed
    rescue ArgumentError
      render "leave_days_unavailable"
    end
  end

  # GET /leave_days/1
  # GET /leave_days/1.json
  def show
  end

  # GET /leave_days/new
  def new
    @leave_day = @user.leave_days.build
    add_breadcrumb(I18n.t('controllers.leave_days.breadcrumbs.new_leave_day'))
  end

  # GET /leave_days/1/edit
  def edit
    @leave_day = LeaveDay.find(params[:id])
  end

  # POST /leave_days
  # POST /leave_days.json
  def create
    successful = false
    @leave_day = @user.leave_days.build
    @leave_day.leave_day_type = leave_day_params[:leave_day_type]

    @leave_day_dates = params[:leave_day_dates]

    dates = params[:leave_day_dates].split(",")
    if dates.size == 0
      successful = false
      #TODO add manual validation error 'missing dates'
    end
    begin
      ActiveRecord::Base.transaction do
        for date in dates
          leave_day = @user.leave_days.build
          leave_day.date = date
          leave_day.leave_day_type = leave_day_params[:leave_day_type]
          begin
            if (!leave_day.save)
              flash[:alert] = I18n.t('controllers.leave_days.could_not_save', date: date)
              break
            end
          rescue ActiveRecord::RecordNotUnique => e
            flash[:alert] = I18n.t('controllers.leave_days.leave_day_already_exists', date: date)
            raise e
          end
        end
        successful = true
      end
    rescue ActiveRecord::RecordNotUnique => e
      logger.error "Error persisting leave day #{e.message}"
    end

    respond_to do |format|
      if successful
        format.html { redirect_to user_leave_days_path(@user), notice: I18n.t('controllers.leave_days.successfully_created') }
        format.json { render :show, status: :created, location: @leave_day }
      else
        format.html { render :new }
        format.json { render json: @leave_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leave_days/1
  # PATCH/PUT /leave_days/1.json
  def update
    @leave_day = LeaveDay.find(params[:id])
    success = false
    begin
      @leave_day.update(leave_day_params)
      success = true
    rescue ActiveRecord::RecordNotUnique
      flash[:alert] = I18n.t('controllers.leave_days.leave_day_for_date_already_exists')
    end

    respond_to do |format|
      if success
        format.html { redirect_to user_leave_days_path(@leave_day.user), notice: I18n.t('controllers.leave_days.successfully_updated') }
        format.json { render :show, status: :ok, location: @leave_day }
      else
        format.html { render :edit }
        format.json { render json: @leave_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leave_days/1
  # DELETE /leave_days/1.json
  def destroy
    @leave_day.destroy
    respond_to do |format|
      format.html { redirect_to user_leave_days_url, notice: I18n.t('controllers.leave_days.successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_leave_day
      @leave_day = LeaveDay.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def leave_day_params
      params.require(:leave_day).permit(:date, :leave_day_type)
    end
end
