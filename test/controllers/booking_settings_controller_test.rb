require "test_helper"

class BookingSettingsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    patch booking_setting_url, params: { booking_setting: {} }

    assert_redirected_to new_user_session_url
  end

  test "saves normalized booking settings for the current coach" do
    user = users(:oneU)
    sign_in user

    assert_enqueued_with(job: CalendarRefreshJob) do
      assert_difference("BookingSetting.count") do
        patch booking_setting_url, params: {
          booking_setting: {
            enabled: "1",
            ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
            timezone: "Europe/Bratislava",
            duration_options_text: "60, 30",
            default_duration: "60",
            minimum_notice_hours: "12",
            buffer_minutes: "15",
            weekly_hours: {
              "1" => { start: "09:00", end: "17:00" },
              "2" => { start: "", end: "" }
            }
          }
        }
      end
    end

    setting = user.reload.booking_setting
    assert_redirected_to edit_user_registration_url(tab: "booking")
    assert_equal [ 30, 60 ], setting.duration_options
    assert_equal({ "1" => [ { "start" => "09:00", "end" => "17:00" } ] }, setting.weekly_hours)
  end

  test "does not save an unsupported calendar" do
    user = users(:oneU)
    sign_in user

    assert_no_difference("BookingSetting.count") do
      patch booking_setting_url, params: {
        booking_setting: {
          enabled: "1",
          ics_url: "https://example.com/calendar.ics",
          timezone: "UTC",
          duration_options_text: "60",
          default_duration: "60",
          minimum_notice_hours: "24",
          buffer_minutes: "15",
          weekly_hours: { "1" => { start: "09:00", end: "17:00" } }
        }
      }
    end

    assert_redirected_to edit_user_registration_url(tab: "booking")
    assert_equal "Calendar link must be a private Google or Outlook HTTPS calendar URL", flash[:alert]
  end
end
