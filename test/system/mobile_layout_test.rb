require "application_system_test_case"
require "warden/test/helpers"

class MobileLayoutTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @client = clients(:oneC)
    @session = sessions(:oneS)
    login_as users(:oneU), scope: :user
    page.current_window.resize_to(375, 812)
  end

  teardown do
    Warden.test_reset!
    page.current_window.resize_to(1400, 1400)
  end

  test "primary screens fit a mobile viewport" do
    [
      root_url,
      clients_url,
      new_client_url,
      edit_client_url(@client),
      client_url(@client),
      start_session_url,
      new_client_session_url(@client),
      edit_client_session_url(@client, @session),
      client_session_url(@client, @session),
      edit_user_registration_url,
      edit_user_registration_url(tab: "booking")
    ].each do |url|
      visit url
      assert_no_horizontal_overflow
    end
  end

  test "booking settings explain the flow and start the week on Monday" do
    visit edit_user_registration_url(tab: "booking")

    assert_text "Nothing is added to your sessions until you review and confirm it."
    assert_link coach_homepage_url(username: users(:oneU).user_profile.username)

    time_labels = all("input[type='time']").map { |input| input["aria-label"] }
    assert_equal "Monday start", time_labels.first
    assert_equal "Sunday end", time_labels.last
  end

  test "public booking form fits a mobile viewport" do
    profile = users(:oneU).user_profile
    setting = BookingSetting.create!(
      user: profile.user,
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "UTC",
      minimum_notice_hours: 0
    )
    starts_at = 2.days.from_now.change(hour: 9, min: 0, sec: 0).utc
    slot = AvailableSlotFinder::Slot.new(
      starts_at:,
      ends_at: starts_at + setting.default_duration.minutes,
      visitor_starts_at: starts_at.in_time_zone("UTC"),
      coach_starts_at: starts_at.in_time_zone("UTC")
    )

    with_available_slots([ slot ]) do
      visit coach_homepage_url(username: profile.username)
      assert_text "Book a session"
      assert_no_horizontal_overflow
    end
  end

  private

    def assert_no_horizontal_overflow
      viewport_width, page_width = page.evaluate_script(<<~JS)
        [document.documentElement.clientWidth, document.documentElement.scrollWidth]
      JS

      assert_equal viewport_width, page_width, "#{page.current_path} overflows horizontally"
    end
end
