require "icalendar/recurrence"

class IcsBusyIntervalParser
  def initialize(body, window_start:, window_end:, coach_timezone:)
    @body = body
    @window_start = window_start
    @window_end = window_end
    @coach_zone = ActiveSupport::TimeZone[coach_timezone]
  end

  def call
    calendars = Icalendar::Calendar.parse(@body)
    events = calendars.flat_map(&:events)
    overridden_starts = overridden_starts_by_uid(events)

    events.flat_map do |event|
      next [] if cancelled?(event) || transparent?(event)

      intervals_for(event, overridden_starts[event.uid.to_s])
    end.uniq.sort_by(&:first)
  rescue Icalendar::Parser::ParseError, ArgumentError, NoMethodError => error
    raise IcsCalendarFetcher::Error, "Calendar data could not be parsed: #{error.message}"
  end

  private

  def overridden_starts_by_uid(events)
    events.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |event, result|
      next if event.recurrence_id.blank?

      result[event.uid.to_s] << utc_time(event.recurrence_id)
    end
  end

  def intervals_for(event, overridden_starts)
    if event.recurrence_id.present?
      interval = direct_interval(event)
      return interval ? [ interval ] : []
    end

    event.occurrences_between(@window_start, @window_end).filter_map do |occurrence|
      starts_at = utc_time(occurrence.start_time)
      next if overridden_starts.include?(starts_at)

      ends_at = utc_time(occurrence.end_time) if occurrence.end_time
      ends_at ||= starts_at + event_duration(event)
      [ starts_at, ends_at ] if overlaps_window?(starts_at, ends_at)
    end
  end

  def direct_interval(event)
    starts_at = utc_time(event.dtstart)
    ends_at = event.dtend.present? ? utc_time(event.dtend) : starts_at + event_duration(event)
    [ starts_at, ends_at ] if overlaps_window?(starts_at, ends_at)
  end

  def event_duration(event)
    return utc_time(event.dtend) - utc_time(event.dtstart) if event.dtend.present?
    return event.duration.value if event.duration.present?

    date_value?(event.dtstart) ? 1.day : 0.seconds
  end

  def utc_time(value)
    original = value
    value = value.value if value.respond_to?(:value)

    if value.is_a?(Date) && !value.is_a?(DateTime)
      return @coach_zone.local(value.year, value.month, value.day).utc
    end

    timezone_id = Array(original.ical_params["tzid"]).first if original.respond_to?(:ical_params)
    if timezone_id.present? && (zone = ActiveSupport::TimeZone[timezone_id])
      return zone.local(value.year, value.month, value.day, value.hour, value.min, value.sec).utc
    end

    value.to_time.utc
  end

  def date_value?(value)
    value = value.value if value.respond_to?(:value)
    value.is_a?(Date) && !value.is_a?(DateTime)
  end

  def overlaps_window?(starts_at, ends_at)
    starts_at < @window_end && ends_at > @window_start
  end

  def cancelled?(event)
    event.status.to_s.casecmp("CANCELLED").zero?
  end

  def transparent?(event)
    event.transp.to_s.casecmp("TRANSPARENT").zero?
  end
end
