class Client < ApplicationRecord
  belongs_to :user
  has_many :sessions, dependent: :destroy

  validates :user, :name, presence: true
  validates :email, uniqueness: true, if: :email_present?
  validates :phone, uniqueness: true, if: :phone_present?
  validates :email, presence: true, unless: :phone?
  validates :phone, presence: true, unless: :email?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, if: :email_present?
  validates :phone, length: { minimum: 5, maximum: 15 }, if: :phone_present?
  validates :name, length: { in: 2..128 }

  private

  def email_present?
    email.present?
  end

  def phone_present?
    phone.present?
  end
end
