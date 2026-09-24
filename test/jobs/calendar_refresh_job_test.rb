require "test_helper"

class CalendarRefreshJobTest < ActiveJob::TestCase
  test "ignores disabled booking settings" do
    setting = BookingSetting.create!(user: users(:oneU), enabled: false)

    assert_nothing_raised { CalendarRefreshJob.perform_now(setting.id) }
    assert_nil setting.reload.last_calendar_sync_at
  end
end
