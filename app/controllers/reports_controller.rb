class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  skip_load_resource only: [:content]
  before_action :verify_employment
  before_action :prepare_year_filter, only: [:index]

  include ReportsHelper
  include ReportSummariesHelper
  include LeaveDaysHelper

  def add_breadcrumbs
    super
    add_breadcrumb("Reports", user_reports_path(@user))
  end

  # GET /users/1/reports/current
  def current
    @user = User.find(params[:user_id])
    @report = @user.reports.build
    @report.date = Date.today
    prepare_report()
  end

  # GET /users/1/reports/content
  def content
    if params[:user_id] != current_user.id && !current_user.admin?
      logger.info "only admins are allowed to fetch other users content"
      params[:user_id] = current_user.id
    end
    begin
      @user = User.find(params[:user_id])
      @report = @user.reports.build
      @report.date = Date.new(params[:year].to_i,params[:month].to_i,1)
      @report.date = Date.today if @report.date.nil?
      prepare_report()
      render partial: "report_content", layout: nil
    rescue ArgumentError
      render partial: "report_unavailable", layout: nil
    end
  end

  # GET /reports
  # GET /reports.json
  def index
    @user = User.find(params[:user_id])
    @reports = Report.where(user_id: @user.id, date: (start_of_year(@year)..end_of_year(@year))).order('date ASC')
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    @user = User.find(params[:user_id])
    prepare_report()
    if @report.balance != @report_summary.working_hours_balance || @report.workingHours != @report_summary.working_hours
      logger.error "report has changed since creating it, please generate a new report!"
      flash[:alert] = "Data has been changed after creating a report. Please update the report!"
    end
  end

  # GET /reports/new
  def new
    add_breadcrumb("New Report")
    @user = User.find(params[:user_id])
    @report = @user.reports.build
    @report.date = params[:date]
    @report.date = Date.today if @report.date.nil?
    prepare_report()
  end

  # GET /reports/1/edit
  def edit
    @report = Report.find(params[:id])
    @user = @report.user
    prepare_report()
  end

  # POST /reports
  # POST /reports.json
  def create
    @user = User.find(params[:user_id])
    @report = @user.reports.create(report_params)
    prepare_report()
    @report.balance = @report_summary.working_hours_balance
    @report.workingHours = @report_summary.working_hours

    success = false
    begin
      @report.save
      success = true
    rescue ActiveRecord::RecordNotUnique
      flash[:alert] = "Report for date already exists!"
    end

    respond_to do |format|
      if success
        format.html { redirect_to [@report.user, @report], notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    @report = Report.find(params[:id])
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to [@report.user, @report], notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to user_reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      #@report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      report_params = params[:report]
      if !report_params[:correction_string].nil?
        if report_params[:correction_string].length > 0
          report_params[:correction] = parse_duration(report_params[:correction_string])
        else
          report_params[:correction] = 0
        end
        report_params.delete(:correction_string)
      end

      params.require(:report).permit(:date, :balance, :workingHours, :correction, :correctionReason)
    end

    def prepare_report()
      public_holidays = PublicHoliday.where(date: @report.date.beginning_of_month..@report.date.end_of_month)
      @working_days = process_working_days(@report.date.beginning_of_month,
      @report.date.end_of_month,
      @user.time_entries,
      @user.leave_days,
      @user.employments,
      public_holidays)
      @report_summary = create_report_summary(@working_days, @user.employments, @user.reports)
      @company_name = ENV['COMPANY_NAME']
      @leave_days_available = calculate_available_leave_days(@report.date.end_of_month, @user.employments, @user.leave_days)
      @leave_days_consumed = calculate_consumed_leave_days(@report.date.end_of_month, @user.employments, @user.leave_days)
      @employments = filter_employments(@report.date.beginning_of_month, @report.date.end_of_month, @user.employments)
      if @report_summary.validation_errors?
        flash[:alert] = "Please correct the working day validation errors!"
      end
    end

end
