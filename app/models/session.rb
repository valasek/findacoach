class Session < ApplicationRecord
  belongs_to :client
  belongs_to :service

  default_scope { order(date: :desc) }

  validates :date, presence: true
  validates :duration, presence: true, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 12.0, step: 0.5 }
  validates :paid, inclusion: { in: [ true, false ] }

  validate :service_belongs_to_client_user

  private

  def service_belongs_to_client_user
    if service.present? && client.present? && service.user_id != client.user_id
      errors.add(:service, "must belong to the same user as the client")
    end
  end
end
