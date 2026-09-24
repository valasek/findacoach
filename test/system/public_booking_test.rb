require "application_system_test_case"

class PublicBookingTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup { Warden.test_mode! }
  teardown do
    Warden.test_reset!
    page.current_window.resize_to(1400, 1400)
  end

  test "visitor requests an available coaching session" do
    profile = user_profiles(:one)
    coach = profile.user
    coach.services.update_all(default: false)
    services(:one).update!(default: true)
    BookingSetting.create!(
      user: coach,
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "UTC",
      minimum_notice_hours: 0
    )
    starts_at = 2.days.from_now.change(hour: 9, min: 0, sec: 0).utc
    slot = AvailableSlotFinder::Slot.new(
      starts_at:,
      ends_at: starts_at + 1.hour,
      visitor_starts_at: starts_at.in_time_zone("UTC"),
      coach_starts_at: starts_at.in_time_zone("UTC")
    )

    with_available_slots([ slot ]) do
      visit coach_homepage_url(username: profile.username)
      assert_selector "[data-booking-target='contact'].hidden", visible: :all
      assert_no_button "Show times"
      find("input[name='booking_request[starts_at]']", match: :first).choose
      assert_selector "[data-booking-target='contact']:not(.hidden)"
      assert_equal "booking_request_visitor_name", page.evaluate_script("document.activeElement.id")
      assert_operator page.evaluate_script("document.querySelector('[data-booking-target=contact]').getBoundingClientRect().top"), :<, page.evaluate_script("window.innerHeight")
      fill_in "Your full name", with: "Alex Example"
      fill_in "Email", with: "alex@example.com"
      fill_in "What would you like to achieve?", with: "Prepare for a promotion"
      click_on "Request this session"

      assert_text "Your request was sent"

      login_as coach, scope: :user
      visit booking_requests_url
      click_on "Alex Example"
      fill_in "booking_request_coach_message", with: "Looking forward to our conversation."
      click_on "Confirm session"

      assert_text "Session confirmed"
    end

    booking_request = BookingRequest.last
    assert_equal "alex@example.com", booking_request.visitor_email
    assert booking_request.confirmed?
    assert_equal booking_request.starts_at, booking_request.session.starts_at
  end

  test "later days stay collapsed and changing session length refreshes times" do
    profile = user_profiles(:one)
    BookingSetting.create!(
      user: profile.user,
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "UTC",
      minimum_notice_hours: 0
    )
    starts_at = 2.days.from_now.change(hour: 9, min: 0, sec: 0).utc
    slots = [ starts_at, starts_at + 1.day ].map do |time|
      AvailableSlotFinder::Slot.new(
        starts_at: time,
        ends_at: time + 1.hour,
        visitor_starts_at: time.in_time_zone("UTC"),
        coach_starts_at: time.in_time_zone("UTC")
      )
    end

    with_available_slots(slots) do
      page.current_window.resize_to(375, 812)
      visit coach_homepage_url(username: profile.username)
      assert_selector "details[open]", count: 1
      assert_selector "details:not([open])", count: 1
      assert_text "1 time"
      find("details:not([open]) summary").click
      assert_selector "details[open]", count: 2

      page.execute_script("window.scrollTo(0, 300)")
      position = page.evaluate_script("window.scrollY")
      assert_operator position, :>, 0

      select "30 minutes", from: "Session length"
      assert_current_path(/duration=30/)
      assert_field "Session length", with: "30"
      assert_in_delta position, page.evaluate_script("window.scrollY"), 80

      find("select[name='timezone'] option[value='Europe/Prague']").select_option
      assert_current_path(/timezone=Europe%2FPrague/)
      assert_field "Your timezone", with: "Europe/Prague"
      assert_in_delta position, page.evaluate_script("window.scrollY"), 80
    end
  end
end
