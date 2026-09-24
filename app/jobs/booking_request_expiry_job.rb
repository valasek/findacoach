class BookingRequestExpiryJob < ApplicationJob
  queue_as :default

  def perform
    BookingRequest.pending.where(starts_at: ...Time.current).update_all(
      status: BookingRequest.statuses[:expired],
      decided_at: Time.current,
      updated_at: Time.current
    )
  end
end
