class Client < ApplicationRecord
  belongs_to :user

  validates :user, :name, presence: true
  validates :email, :phone, uniqueness: true
  validates :email, presence: true, unless: :phone?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email_present?
  validates :phone, length: { minimum: 6, maximum: 12 }, if: :phone_present?
  validates :phone, presence: true, unless: :email?
  validates :name, length: { in: 2..128 }

  private

  def email_present?
    email.present?
  end

  def phone_present?
    phone.present?
  end
end
