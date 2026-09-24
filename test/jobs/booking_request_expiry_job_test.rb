require "test_helper"

class BookingRequestExpiryJobTest < ActiveJob::TestCase
  test "expires pending requests after their requested start" do
    expired_request = BookingRequest.create!(
      user: users(:oneU),
      visitor_name: "Past Client",
      visitor_email: "past@example.com",
      goal: "Past request",
      starts_at: 1.minute.ago,
      visitor_timezone: "UTC",
      duration_minutes: 60
    )
    future_request = BookingRequest.create!(
      user: users(:oneU),
      visitor_name: "Future Client",
      visitor_email: "future@example.com",
      goal: "Future request",
      starts_at: 1.day.from_now,
      visitor_timezone: "UTC",
      duration_minutes: 60
    )

    BookingRequestExpiryJob.perform_now

    assert expired_request.reload.expired?
    assert future_request.reload.pending?
  end
end
