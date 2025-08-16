class User < ApplicationRecord
  include UserObserver
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :clients, dependent: :destroy
  has_many :sessions, through: :clients

  def total_coaching_hours
    sessions.sum(:duration)
  end

  def percentage_paid_seesions
    duration_total_sessions = sessions.sum(:duration)
    duration_paid_sessions = sessions.where(paid: true).sum(:duration)

    return 0 if duration_total_sessions == 0

    (duration_paid_sessions.to_f / duration_total_sessions * 100).round(0)
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

    # Create new user
    User.create!(
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      provider: auth.provider,
      uid: auth.uid
    )
  end
end
