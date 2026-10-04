class Client < ApplicationRecord
  belongs_to :user
  has_many :sessions, dependent: :destroy
  has_many :booking_requests, dependent: :nullify

  default_scope { order(:name) }

  validates :user, :name, presence: true
  validates :email, uniqueness: { scope: :user_id, case_sensitive: false }, if: :email_present?
  validates :phone, uniqueness: { scope: :user_id }, if: :phone_present?
  validates :email, presence: true, unless: :phone?
  validates :phone, presence: true, unless: :email?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, if: :email_present?
  validates :phone, length: { minimum: 5, maximum: 15 }, if: :phone_present?
  validates :name, length: { in: 2..128 }

  before_validation :normalize_contact_details

  private

  def email_present?
    email.present?
  end

  def phone_present?
    phone.present?
  end

  def normalize_contact_details
    self.email = email.to_s.strip.downcase.presence
    self.phone = phone.to_s.gsub(/\D/, "").presence
  end
end
