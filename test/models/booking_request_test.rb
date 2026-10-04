require "test_helper"

class BookingRequestTest < ActiveSupport::TestCase
  def valid_request
    BookingRequest.new(
      user: users(:oneU),
      visitor_name: "Alex Example",
      visitor_email: " ALEX@example.com ",
      goal: "Prepare for a leadership transition",
      starts_at: 2.days.from_now,
      visitor_timezone: "Europe/Prague",
      duration_minutes: 60
    )
  end

  test "normalizes contact details and creates an idempotency key" do
    booking_request = valid_request

    assert booking_request.save
    assert_equal "alex@example.com", booking_request.visitor_email
    assert booking_request.idempotency_key.present?
  end

  test "allows only terminal transitions from pending" do
    booking_request = valid_request.tap(&:save!)

    assert booking_request.update(status: :declined, decided_at: Time.current)
    assert_not booking_request.update(status: :confirmed)
  end

  test "deleting the linked session keeps the booking request" do
    session = sessions(:oneS)
    booking_request = valid_request.tap { |r| r.session = session; r.client = session.client; r.save! }

    assert_difference("Session.count", -1) { session.destroy! }
    assert_nil booking_request.reload.session_id
  end

  test "encrypts visitor details" do
    booking_request = valid_request.tap(&:save!)
    stored_value = BookingRequest.connection.select_value("SELECT visitor_email FROM booking_requests WHERE id = #{booking_request.id}")

    assert_not_equal booking_request.visitor_email, stored_value
  end
end
