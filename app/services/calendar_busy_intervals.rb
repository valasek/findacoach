class CalendarBusyIntervals
  FRESH_FOR = 15.minutes
  USABLE_FOR = 24.hours
  # Parsed once over a fixed horizon so a cached entry is valid for any caller window.
  HORIZON = 16.days

  class Unavailable < StandardError; end

  def initialize(setting, cache: Rails.cache, fetcher_class: IcsCalendarFetcher)
    @setting = setting
    @cache = cache
    @fetcher_class = fetcher_class
  end

  def call(window_start:, window_end:)
    cached = @cache.read(cache_key)
    intervals = fresh?(cached) ? deserialize(cached[:intervals]) : refresh(cached)
    overlapping(intervals, window_start, window_end)
  rescue IcsCalendarFetcher::Error => error
    mark_failed(error.message)
    return overlapping(deserialize(cached[:intervals]), window_start, window_end) if usable?(cached)

    raise Unavailable, "Calendar availability is temporarily unavailable"
  end

  private

  def overlapping(intervals, window_start, window_end)
    intervals.select { |starts_at, ends_at| starts_at < window_end && ends_at > window_start }
  end

  def refresh(cached)
    result = @fetcher_class.new(@setting.ics_url, etag: cached&.dig(:etag)).call
    intervals = if result.not_modified && cached
      cached[:intervals]
    else
      parsed = IcsBusyIntervalParser.new(
        result.body,
        window_start: Time.current.utc,
        window_end: HORIZON.from_now.utc,
        coach_timezone: @setting.timezone
      ).call
      serialize(parsed)
    end

    payload = { intervals:, etag: result.etag || cached&.dig(:etag), fetched_at: Time.current.iso8601 }
    @cache.write(cache_key, payload, expires_in: USABLE_FOR)
    mark_synced
    deserialize(intervals)
  end

  def fresh?(cached)
    cached && Time.iso8601(cached[:fetched_at]) >= FRESH_FOR.ago
  end

  def usable?(cached)
    cached && Time.iso8601(cached[:fetched_at]) >= USABLE_FOR.ago
  end

  def serialize(intervals)
    intervals.map { |starts_at, ends_at| [ starts_at.iso8601, ends_at.iso8601 ] }
  end

  def deserialize(intervals)
    intervals.map { |starts_at, ends_at| [ Time.iso8601(starts_at), Time.iso8601(ends_at) ] }
  end

  def cache_key
    "booking-calendar/#{@setting.id}/#{@setting.updated_at.to_i}"
  end

  def mark_synced
    @setting.update_columns(
      last_calendar_sync_at: Time.current,
      calendar_sync_status: "synced",
      calendar_sync_error: nil
    )
  end

  def mark_failed(message)
    @setting.update_columns(calendar_sync_status: "error", calendar_sync_error: message)
  end
end
