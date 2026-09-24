require "test_helper"

class BookingRequestConfirmerTest < ActiveSupport::TestCase
  setup do
    @coach = users(:oneU)
    @coach.services.update_all(default: false)
    services(:one).update!(default: true)
    @setting = BookingSetting.create!(
      user: @coach,
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "Europe/Bratislava"
    )
    @booking_request = BookingRequest.create!(
      user: @coach,
      visitor_name: "Alex Example",
      visitor_email: "alex@example.com",
      goal: "Prepare for a promotion",
      starts_at: Time.utc(2026, 9, 28, 8),
      visitor_timezone: "Europe/Prague",
      duration_minutes: 60
    )
    @slot = AvailableSlotFinder::Slot.new(
      starts_at: @booking_request.starts_at,
      ends_at: @booking_request.starts_at + 1.hour,
      visitor_starts_at: @booking_request.starts_at.in_time_zone("Europe/Prague"),
      coach_starts_at: @booking_request.starts_at.in_time_zone("Europe/Bratislava")
    )
  end

  test "atomically creates a client and session" do
    with_available_slots([ @slot ]) do
      assert_difference([ "Client.count", "Session.count" ], 1) do
        BookingRequestConfirmer.new(@booking_request).call(coach_message: "Looking forward to meeting you.")
      end
    end

    @booking_request.reload
    assert @booking_request.confirmed?
    assert_equal @booking_request.starts_at, @booking_request.session.starts_at
    assert_equal Date.new(2026, 9, 28), @booking_request.session.date
    assert_equal "Prepare for a promotion", @booking_request.session.notes
    assert_predicate @booking_request.session, :paid?
  end

  test "does not create records when the slot is unavailable" do
    with_available_slots([]) do
      assert_no_difference([ "Client.count", "Session.count" ]) do
        assert_raises(BookingRequestConfirmer::SlotUnavailable) do
          BookingRequestConfirmer.new(@booking_request).call
        end
      end
    end

    assert @booking_request.reload.pending?
  end
end
