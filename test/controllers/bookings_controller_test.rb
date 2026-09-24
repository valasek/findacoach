require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = user_profiles(:one)
    @coach = @profile.user
    @setting = BookingSetting.create!(
      user: @coach,
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "UTC",
      weekly_hours: { "1" => [ { "start" => "09:00", "end" => "17:00" } ] }
    )
    starts_at = Time.utc(2026, 9, 28, 9)
    @slot = AvailableSlotFinder::Slot.new(
      starts_at:,
      ends_at: starts_at + 1.hour,
      visitor_starts_at: starts_at.in_time_zone("Europe/Prague"),
      coach_starts_at: starts_at.in_time_zone("UTC")
    )
  end

  test "legacy booking page redirects to the coach homepage with filters" do
    get new_coach_booking_url(username: @profile.username), params: { timezone: "Europe/Prague", duration: 60 }

    assert_redirected_to coach_homepage_url(username: @profile.username, timezone: "Europe/Prague", duration: 60)
  end

  test "coach homepage shows available booking slots" do
    with_available_slots([ @slot ]) do
      get coach_homepage_url(username: @profile.username), params: { timezone: "Europe/Prague", duration: 60 }
    end

    assert_response :success
    assert_select "h2", "Book a session"
    assert_select "input[type=radio][name='booking_request[starts_at]']", count: 1
  end

  test "creates only a pending request and enqueues both emails" do
    assert_enqueued_emails 2 do
      assert_difference("BookingRequest.count") do
        assert_no_difference([ "Client.count", "Session.count" ]) do
          with_available_slots([ @slot ]) do
            post coach_bookings_url(username: @profile.username), params: {
              booking_request: {
                visitor_name: "Alex Example",
                visitor_email: "alex@example.com",
                goal: "Prepare for a promotion",
                starts_at: @slot.starts_at.iso8601,
                visitor_timezone: "Europe/Prague",
                duration_minutes: 60,
                idempotency_key: SecureRandom.uuid
              }
            }
          end
        end
      end
    end

    assert_redirected_to received_coach_bookings_url(username: @profile.username)
    assert BookingRequest.last.pending?
  end

  test "rejects a slot that is no longer available" do
    assert_no_difference("BookingRequest.count") do
      with_available_slots([]) do
        post coach_bookings_url(username: @profile.username), params: {
          booking_request: {
            visitor_name: "Alex Example",
            visitor_email: "alex@example.com",
            goal: "Prepare for a promotion",
            starts_at: @slot.starts_at.iso8601,
            visitor_timezone: "UTC",
            duration_minutes: 60,
            idempotency_key: SecureRandom.uuid
          }
        }
      end
    end

    assert_response :unprocessable_entity
    assert_select ".alert-error"
  end

  test "shows a generic receipt page" do
    get received_coach_bookings_url(username: @profile.username)

    assert_response :success
    assert_select "h1", "Your request was sent"
  end
end
