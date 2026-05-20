class User < ApplicationRecord
  include UserObserver
  devise :database_authenticatable, :registerable, :confirmable, :trackable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :clients, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :sessions, through: :clients
  has_one :user_profile, dependent: :destroy
  accepts_nested_attributes_for :user_profile, update_only: true

  # create a profile after user creation
  after_create :create_user_profile
  after_create :create_default_service

  # Delegate common methods for convenience
  # delegate :full_name, :website, :bio, :photo, to: :user_profile, allow_nil: true

  def total_coaching_hours
    sessions.sum(:duration)
  end

  def percentage_paid_seesions
    duration_total_sessions = sessions.sum(:duration)
    duration_paid_sessions = sessions.where(paid: true).sum(:duration)

    return 0 if duration_total_sessions == 0

    (duration_paid_sessions.to_f / duration_total_sessions * 100).round(0)
  end

  def sso_user?
    # Adjust based on your SSO implementation
    encrypted_password.blank? || providers.present?
  end

  def providers
    # Return array of connected providers
    # This depends on your SSO setup
    [ self.provider ] if self.provider
  end

  def self.from_omniauth(auth)
    # Try to find user by provider and uid first
    user = User.find_by(provider: auth.provider, uid: auth.uid)

    if user
      return user
    end

    # Try to find existing user by email
    user = User.find_by(email: auth.info.email)

    if user
      # Link the OAuth account to existing user
      user.update(provider: auth.provider, uid: auth.uid)
      return user
    end

    # Create new user — skip confirmation since Google has already verified the address
    user = User.new(
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      provider: auth.provider,
      uid: auth.uid
    )
    user.skip_confirmation!
    user.save!
    user
  end

  def after_confirmation
    UserMailer.welcome_email(self).deliver_later
  end

  private

  def create_user_profile
    build_user_profile.save!
  end

  def create_default_service
    services.create!(name: "Coaching", default: true)
  end
end
