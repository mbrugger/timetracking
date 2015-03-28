class EmploymentsController < ApplicationController
  include EmploymentsHelper

  before_action :set_employment, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :user
  load_and_authorize_resource :employment, through: :user


  def add_breadcrumbs
    super
    add_breadcrumb("Employments", user_employments_path(@user))
  end

  # GET /employments
  # GET /employments.json
  def index
    @employments = @user.employments
  end

  # GET /employments/1
  # GET /employments/1.json
  def show
  end

  # GET /employments/new
  def new
    @employment = @user.employments.build
    add_breadcrumb("New Employment")
  end

  # GET /employments/1/edit
  def edit
    @employment = Employment.find(params[:id])
  end

  # POST /employments
  # POST /employments.json
  def create
    @employment = @user.employments.create(employment_params)
    respond_to do |format|
      if @employment.save
        format.html { redirect_to user_employments_path(@employment.user), notice: 'Employment was successfully created.' }
        format.json { render :show, status: :created, location: @employment }
      else
        format.html { render :new }
        format.json { render json: @employment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employments/1
  # PATCH/PUT /employments/1.json
  def update
    @employment = Employment.find(params[:id])
    respond_to do |format|
      if @employment.update(employment_params)
        format.html { redirect_to user_employments_path(@employment.user), notice: 'Employment was successfully updated.' }
        format.json { render :show, status: :ok, location: @employment }
      else
        format.html { render :edit }
        format.json { render json: @employment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employments/1
  # DELETE /employments/1.json
  def destroy
    @employment.destroy
    respond_to do |format|
      format.html { redirect_to user_employments_url, notice: 'Employment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employment
      @employment = Employment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employment_params
      employment = params[:employment]
      if !employment[:working_hours_balance_string].nil?
        if employment[:working_hours_balance_string].length>0
          employment[:working_hours_balance] = parse_duration(employment[:working_hours_balance_string])
        end
        employment.delete(:working_hours_balance_string)
      end
      params.require(:employment).permit(:startDate, :endDate, :weeklyHours, :leave_days, :working_hours_balance, :migrated_employment)
    end
end
