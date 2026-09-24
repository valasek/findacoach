require "test_helper"

class BookingRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coach = users(:oneU)
    @coach.services.update_all(default: false)
    services(:one).update!(default: true)
    @setting = BookingSetting.create!(
      user: @coach,
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "UTC"
    )
    @booking_request = BookingRequest.create!(
      user: @coach,
      visitor_name: "Alex Example",
      visitor_email: "alex@example.com",
      goal: "Prepare for a promotion",
      starts_at: Time.utc(2026, 9, 28, 9),
      visitor_timezone: "Europe/Prague",
      duration_minutes: 60
    )
    @slot = AvailableSlotFinder::Slot.new(
      starts_at: @booking_request.starts_at,
      ends_at: @booking_request.starts_at + 1.hour,
      visitor_starts_at: @booking_request.starts_at.in_time_zone("Europe/Prague"),
      coach_starts_at: @booking_request.starts_at.in_time_zone("UTC")
    )
    sign_in @coach
  end

  test "lists and shows the coach's requests" do
    get booking_requests_url
    assert_response :success
    assert_select "a[href=?]", booking_request_path(@booking_request)

    get booking_request_url(@booking_request)
    assert_response :success
    assert_select "h1", "Alex Example"
    assert_select "input[type=submit][value='Confirm session']"
    assert_select "input[type=submit][value='Decline request']"
    assert_select "[data-turbo-confirm]", false
  end

  test "confirms an available request and enqueues two emails" do
    with_available_slots([ @slot ]) do
      assert_enqueued_emails 2 do
        patch confirm_booking_request_url(@booking_request), params: {
          booking_request: { coach_message: "See you then." }
        }
      end
    end

    assert_redirected_to booking_request_url(@booking_request)
    assert @booking_request.reload.confirmed?
  end

  test "declines a request and enqueues an email" do
    assert_enqueued_emails 1 do
      patch decline_booking_request_url(@booking_request), params: {
        booking_request: { coach_message: "Please choose another time." }
      }
    end

    assert_redirected_to booking_request_url(@booking_request)
    assert @booking_request.reload.declined?
  end

  test "does not expose another coach's request" do
    sign_out @coach
    sign_in users(:twoU)

    get booking_request_url(@booking_request)

    assert_response :not_found
  end
end
