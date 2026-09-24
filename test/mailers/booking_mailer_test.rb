require "test_helper"

class BookingMailerTest < ActionMailer::TestCase
  setup do
    coach = users(:oneU)
    BookingSetting.create!(user: coach, timezone: "UTC")
    @booking_request = BookingRequest.create!(
      user: coach,
      visitor_name: "Alex Example",
      visitor_email: "alex@example.com",
      goal: "Prepare for a promotion",
      starts_at: Time.utc(2026, 9, 28, 9),
      visitor_timezone: "Europe/Prague",
      duration_minutes: 60,
      decided_at: Time.utc(2026, 9, 21, 9)
    )
  end

  test "visitor confirmation includes a calendar attachment without the goal" do
    email = BookingMailer.confirmed_for_visitor(@booking_request)

    assert_equal [ "alex@example.com" ], email.to
    assert_equal "text/calendar", email.attachments.first.mime_type
    calendar = email.attachments.first.body.decoded
    assert_includes calendar, "UID:booking-request-#{@booking_request.id}@findacoach.eu"
    assert_includes calendar, "DTSTART:20260928T090000Z"
    assert_includes calendar, "DTEND:20260928T100000Z"
    assert_not_includes calendar, @booking_request.goal
  end

  test "decline includes the coach message" do
    @booking_request.update!(status: :declined, coach_message: "Please choose another time.")
    email = BookingMailer.declined(@booking_request)

    assert_includes email.body.encoded, "Please choose another time."
  end
end
