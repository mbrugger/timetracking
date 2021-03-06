class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :additional_breadcrumbs

  load_and_authorize_resource

  def add_breadcrumbs
    super
    add_breadcrumb(I18n.t('controllers.users.breadcrumbs.users'), users_path)
  end

  def additional_breadcrumbs
    unless @user.nil?
      add_breadcrumb(@user.visible_name, user_path(@user))
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/my
  # GET /users/my.json
  def my
    @user = current_user
    if @user != nil
      redirect_to @user
    else
      redirect_to users_url
    end
  end

  # GET /users/new
  def new
    add_breadcrumb(I18n.t('controllers.users.breadcrumbs.new_user'))
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.password = random_password
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.reset_password_token = hashed_token
    @user.reset_password_sent_at = Time.now.utc

    respond_to do |format|
      if @user.save
        if params[:notify_user]
          Rails.logger.info "Sending account created message to user #{@user.email}"
          UserMailer.notify_account_created(@user, raw_token).deliver
        end
        format.html { redirect_to @user, notice: I18n.t('controllers.users.successfully_created') }
        format.json { render :show, status: :created, location: @user }
      else
        logger.info "error saving"
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: I18n.t('controllers.users.successfully_updated') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: I18n.t('controllers.users.successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  private

    def random_password
      o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      string = (0...16).map { o[rand(o.length)] }.join
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:time_zone, :name, :role, :email, :validate_working_days)
    end
end
