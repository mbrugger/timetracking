class Api::V1::ApiApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  prepend_before_action :authenticate_api, unless: :api_login_controller?

  def get_auth_token
    request.headers["HTTP_X_API_AUTH_TOKEN"]
  end

  def authenticate_api
    logger.debug "Authenticating api request"
    @api_user = nil
    # fetch user by api key
    token = get_auth_token

    if !token.nil? && token.length > 0
      @api_user = User.where(token: token).first
    else
      logger.info "Missing HTTP Header X-API-AUTH-TOKEN"
    end

    if @api_user.nil?
      logger.info "Could not find user with X-API-AUTH-TOKEN: #{token}"
      redirect_to :root, :status => 401
      return false
    end
  end

  def api_user_signed_in?
    return !@api_user.nil?
  end

  def api_user
    @api_user
  end

  def user_for_paper_trail
    # Save the user responsible for the action
    api_user_signed_in? ? api_user.id : 'API_Guest'
  end

  def api_login_controller?
    return false
  end

end
