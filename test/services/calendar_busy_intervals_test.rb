require "test_helper"

class CalendarBusyIntervalsTest < ActiveSupport::TestCase
  FailingFetcher = Class.new do
    def initialize(*)
    end

    def call
      raise IcsCalendarFetcher::Error, "Calendar could not be reached safely"
    end
  end

  setup do
    @setting = BookingSetting.create!(
      user: users(:oneU),
      enabled: true,
      ics_url: "https://calendar.google.com/calendar/ical/private/basic.ics",
      timezone: "UTC"
    )
    @cache = ActiveSupport::Cache::MemoryStore.new
    @cache_key = "booking-calendar/#{@setting.id}/#{@setting.updated_at.to_i}"
  end

  test "uses cached intervals for up to twenty four hours when refresh fails" do
    busy_start = 2.hours.from_now.change(usec: 0).utc
    @cache.write(@cache_key, {
      intervals: [ [ busy_start.iso8601, (busy_start + 1.hour).iso8601 ] ],
      etag: "calendar-v1",
      fetched_at: 1.hour.ago.iso8601
    })

    intervals = CalendarBusyIntervals.new(@setting, cache: @cache, fetcher_class: FailingFetcher).call(
      window_start: Time.current,
      window_end: 14.days.from_now
    )

    assert_equal busy_start, intervals.first.first
    assert_equal "error", @setting.reload.calendar_sync_status
  end

  test "does not use calendar data older than twenty four hours" do
    @cache.write(@cache_key, {
      intervals: [],
      fetched_at: 25.hours.ago.iso8601
    }, expires_in: 2.days)

    assert_raises(CalendarBusyIntervals::Unavailable) do
      CalendarBusyIntervals.new(@setting, cache: @cache, fetcher_class: FailingFetcher).call(
        window_start: Time.current,
        window_end: 14.days.from_now
      )
    end
  end
end
