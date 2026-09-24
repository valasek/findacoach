class BookingRequest < ApplicationRecord
  belongs_to :user
  belongs_to :client, optional: true
  belongs_to :session, optional: true

  encrypts :visitor_name, :visitor_email, :goal, :coach_message

  enum :status, { pending: "pending", confirmed: "confirmed", declined: "declined", expired: "expired" }, default: :pending, validate: true

  validates :visitor_name, presence: true, length: { in: 2..128 }
  validates :visitor_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :goal, presence: true, length: { maximum: 2000 }
  validates :coach_message, length: { maximum: 1000 }
  validates :starts_at, :visitor_timezone, presence: true
  validates :duration_minutes, inclusion: { in: (15..180).step(15).to_a }
  validates :idempotency_key, presence: true, uniqueness: true
  validate :visitor_timezone_exists
  validate :status_transition_is_allowed, on: :update

  before_validation :normalize_visitor_email
  before_validation :set_idempotency_key, on: :create

  private

  def normalize_visitor_email
    self.visitor_email = visitor_email.to_s.strip.downcase if visitor_email.present?
  end

  def set_idempotency_key
    self.idempotency_key ||= SecureRandom.uuid
  end

  def visitor_timezone_exists
    TZInfo::Timezone.get(visitor_timezone) if visitor_timezone.present?
  rescue TZInfo::InvalidTimezoneIdentifier
    errors.add(:visitor_timezone, "is not valid")
  end

  def status_transition_is_allowed
    return unless will_save_change_to_status?

    previous_status = status_in_database
    allowed = previous_status == "pending" && %w[confirmed declined expired].include?(status)
    errors.add(:status, "cannot change from #{previous_status}") unless allowed
  end
end
