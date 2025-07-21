class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
end
