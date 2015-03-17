class Api::V1::ApiLoginController < Api::V1::ApiApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def api_login_controller?
    return true
  end

  def login
    if current_user.token.nil?
      current_user.token = generate_authentication_token
      current_user.save
    end
    render json: { token: current_user.token }
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(token: token).first
    end
  end

end
