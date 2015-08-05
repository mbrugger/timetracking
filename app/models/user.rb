class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :time_entries
  has_many :employments
  has_many :leave_days
  has_many :reports

  has_paper_trail skip: [:encrypted_password, :reset_password_token, :reset_password_sent_at,
    :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip,
    :last_sign_in_ip, :created_at, :updated_at]


  def admin?
    self.role == "admin"
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(token: token).first
    end
  end

  def visible_name
    if !self.name.nil? &&self.name.length > 0
      self.name
    else
      self.email
    end
  end

  def self.roles
    ['user', 'admin']
  end

  def self.localized_roles
    User.roles.map { |role| [ I18n.t(role, scope: "models.users.roles"), role] }
  end
end
