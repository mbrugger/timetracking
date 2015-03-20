class ApplicationController < ActionController::Base
  before_action :set_timezone
  before_action :set_user
  before_action :add_breadcrumbs
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!, unless: :devise_controller?

  include YearFilterHelper
  include ApplicationHelper
  include BreadcrumbsHelper

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  before_filter do
    resource = controller_path.singularize.gsub('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def user_for_paper_trail
    # Save the user responsible for the action
    user_signed_in? ? current_user.id : 'Guest'
  end

  private
    def set_user
      unless params[:user_id].nil?
        @user = User.find(params[:user_id])
      end
    end

    def add_breadcrumbs
      @breadcrumbs = []
      if !@user.nil? && @user != current_user
        add_breadcrumb("Users", users_path)
        add_breadcrumb(@user.visible_name, user_path(@user))
      elsif current_user == @user
        add_breadcrumb("Home", root_path)
      end
    end

    def set_timezone
      if !current_user.nil? && !current_user.time_zone.nil?
        Time.zone = current_user.time_zone
      end
    end

    def verify_employment
      if current_user.employments.size == 0
        redirect_to root_path, alert: 'Please ask your administrator to create an employment first.'
      end
    end

    def prepare_year_filter
      @year = params[:year].to_i
      @year = Date.today.year if @year == 0
    end
end