class AvailableSlotFinder
  Slot = Data.define(:starts_at, :ends_at, :visitor_starts_at, :coach_starts_at)

  def initialize(setting, busy_intervals: CalendarBusyIntervals.new(setting), now: Time.current)
    @setting = setting
    @busy_intervals = busy_intervals
    @now = now
    @coach_zone = ActiveSupport::TimeZone[setting.timezone]
  end

  def call(duration_minutes:, visitor_timezone:)
    duration = Integer(duration_minutes)
    raise ArgumentError, "Duration is not offered" unless @setting.duration_options.include?(duration)

    visitor_zone = ActiveSupport::TimeZone[visitor_timezone]
    raise ArgumentError, "Visitor timezone is invalid" unless visitor_zone

    window_start = @now.utc
    window_end = (@now.in_time_zone(@coach_zone).to_date + 14.days).in_time_zone(@coach_zone).utc
    busy = busy_intervals(window_start, window_end)

    candidate_slots(duration, window_start, window_end).reject do |starts_at, ends_at|
      conflicts?(starts_at, ends_at, busy)
    end.map do |starts_at, ends_at|
      Slot.new(
        starts_at:,
        ends_at:,
        visitor_starts_at: starts_at.in_time_zone(visitor_zone),
        coach_starts_at: starts_at.in_time_zone(@coach_zone)
      )
    end
  end

  # Confirmation only asks whether the time is still free. Offering rules such as
  # minimum notice or working hours must not block a request the coach already received.
  def free?(starts_at:, duration_minutes:)
    starts_at = starts_at.utc
    ends_at = starts_at + Integer(duration_minutes).minutes

    !conflicts?(starts_at, ends_at, busy_intervals(starts_at, ends_at))
  end

  private

  def busy_intervals(window_start, window_end)
    @busy_intervals.call(window_start:, window_end:) + confirmed_session_intervals(window_start, window_end)
  end

  def candidate_slots(duration, window_start, window_end)
    first_date = window_start.in_time_zone(@coach_zone).to_date
    earliest_start = @now + @setting.minimum_notice_hours.hours
    buffer = @setting.buffer_minutes.minutes

    14.times.flat_map do |offset|
      date = first_date + offset.days
      Array(@setting.weekly_hours[date.wday.to_s]).flat_map do |interval|
        working_start = local_time(date, interval["start"])
        working_end = local_time(date, interval["end"])
        slots = []
        starts_at = working_start

        while starts_at + duration.minutes <= working_end
          ends_at = starts_at + duration.minutes
          slots << [ starts_at.utc, ends_at.utc ] if starts_at >= earliest_start && starts_at.utc < window_end
          starts_at += 30.minutes
        end

        slots
      end
    end
  end

  def local_time(date, value)
    hour, minute = value.split(":").map(&:to_i)
    @coach_zone.local(date.year, date.month, date.day, hour, minute)
  end

  def confirmed_session_intervals(window_start, window_end)
    @setting.user.sessions.unscope(:order)
      .where(starts_at: window_start...window_end)
      .map { |session| [ session.starts_at, session.starts_at + session.duration.to_f.hours ] }
  end

  def conflicts?(starts_at, ends_at, busy_intervals)
    buffer = @setting.buffer_minutes.minutes
    busy_intervals.any? do |busy_start, busy_end|
      starts_at < busy_end + buffer && ends_at + buffer > busy_start
    end
  end
end
