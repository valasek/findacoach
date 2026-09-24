require "test_helper"

class BookingSettingTest < ActiveSupport::TestCase
  test "accepts a supported calendar and working schedule" do
    setting = BookingSetting.new(
      user: users(:oneU),
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "Europe/Bratislava",
      weekly_hours: { "1" => [ { "start" => "09:00", "end" => "17:00" } ] }
    )

    assert setting.valid?
    assert setting.booking_ready?
  end

  test "rejects unsupported calendar hosts and overlapping hours" do
    setting = BookingSetting.new(
      user: users(:oneU),
      ics_url: "https://example.com/calendar.ics",
      weekly_hours: {
        "1" => [
          { "start" => "09:00", "end" => "12:00" },
          { "start" => "11:00", "end" => "13:00" }
        ]
      }
    )

    assert_not setting.valid?
    assert setting.errors[:ics_url].any?
    assert setting.errors[:weekly_hours].any?
  end

  test "encrypts the calendar URL" do
    setting = BookingSetting.create!(
      user: users(:oneU),
      ics_url: "https://outlook.office365.com/owa/calendar/private/calendar.ics"
    )
    stored_value = BookingSetting.connection.select_value("SELECT ics_url FROM booking_settings WHERE id = #{setting.id}")

    assert_not_equal setting.ics_url, stored_value
  end

  test "accepts Outlook.com published calendar links" do
    setting = BookingSetting.new(
      user: users(:oneU),
      ics_url: "https://outlook.live.com/owa/calendar/private/calendar.ics"
    )

    assert setting.valid?
  end
end
