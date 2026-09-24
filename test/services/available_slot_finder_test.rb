require "test_helper"

class AvailableSlotFinderTest < ActiveSupport::TestCase
  FakeBusyIntervals = Data.define(:intervals) do
    def call(window_start:, window_end:)
      intervals
    end
  end

  test "returns only slots inside working hours that do not overlap busy time" do
    setting = BookingSetting.create!(
      user: users(:oneU),
      timezone: "UTC",
      weekly_hours: { "1" => [ { "start" => "09:00", "end" => "12:00" } ] },
      duration_options: [ 60 ],
      default_duration: 60,
      minimum_notice_hours: 0,
      buffer_minutes: 0
    )
    busy = FakeBusyIntervals.new([ [ Time.utc(2026, 9, 21, 10), Time.utc(2026, 9, 21, 11) ] ])

    slots = AvailableSlotFinder.new(setting, busy_intervals: busy, now: Time.utc(2026, 9, 21, 6)).call(
      duration_minutes: 60,
      visitor_timezone: "Europe/Prague"
    )
    first_day_slots = slots.select { |slot| slot.coach_starts_at.to_date == Date.new(2026, 9, 21) }

    assert_equal [ Time.utc(2026, 9, 21, 9), Time.utc(2026, 9, 21, 11) ], first_day_slots.map(&:starts_at)
    assert_equal [ 11, 13 ], first_day_slots.map { |slot| slot.visitor_starts_at.hour }
  end

  test "confirmed sessions block slots" do
    setting = BookingSetting.create!(
      user: users(:oneU),
      timezone: "UTC",
      weekly_hours: { "1" => [ { "start" => "09:00", "end" => "11:00" } ] },
      duration_options: [ 60 ],
      default_duration: 60,
      minimum_notice_hours: 0,
      buffer_minutes: 0
    )
    sessions(:oneS).update!(starts_at: Time.utc(2026, 9, 21, 9), date: Date.new(2026, 9, 21), duration: 1)
    busy = FakeBusyIntervals.new([])

    slots = AvailableSlotFinder.new(setting, busy_intervals: busy, now: Time.utc(2026, 9, 21, 6)).call(
      duration_minutes: 60,
      visitor_timezone: "UTC"
    )
    first_day_slots = slots.select { |slot| slot.coach_starts_at.to_date == Date.new(2026, 9, 21) }

    assert_equal [ Time.utc(2026, 9, 21, 10) ], first_day_slots.map(&:starts_at)
  end

  test "another coach's sessions do not block availability" do
    setting = BookingSetting.create!(
      user: users(:oneU),
      timezone: "UTC",
      weekly_hours: { "1" => [ { "start" => "09:00", "end" => "10:00" } ] },
      duration_options: [ 60 ],
      default_duration: 60,
      minimum_notice_hours: 0,
      buffer_minutes: 0
    )
    sessions(:twoS).update!(starts_at: Time.utc(2026, 9, 21, 9), date: Date.new(2026, 9, 21), duration: 1)
    busy = FakeBusyIntervals.new([])

    slots = AvailableSlotFinder.new(setting, busy_intervals: busy, now: Time.utc(2026, 9, 21, 6)).call(
      duration_minutes: 60,
      visitor_timezone: "UTC"
    )
    first_day_slots = slots.select { |slot| slot.coach_starts_at.to_date == Date.new(2026, 9, 21) }

    assert_equal [ Time.utc(2026, 9, 21, 9) ], first_day_slots.map(&:starts_at)
  end

  test "the buffer does not remove the last slot of the working day" do
    setting = BookingSetting.create!(
      user: users(:oneU),
      timezone: "UTC",
      weekly_hours: { "1" => [ { "start" => "09:00", "end" => "11:00" } ] },
      duration_options: [ 60 ],
      default_duration: 60,
      minimum_notice_hours: 0,
      buffer_minutes: 15
    )
    busy = FakeBusyIntervals.new([])

    slots = AvailableSlotFinder.new(setting, busy_intervals: busy, now: Time.utc(2026, 9, 21, 6)).call(
      duration_minutes: 60,
      visitor_timezone: "UTC"
    )
    first_day_slots = slots.select { |slot| slot.coach_starts_at.to_date == Date.new(2026, 9, 21) }

    assert_equal [ Time.utc(2026, 9, 21, 9), Time.utc(2026, 9, 21, 9, 30), Time.utc(2026, 9, 21, 10) ], first_day_slots.map(&:starts_at)
  end

  test "free? ignores offering rules and reports only real conflicts" do
    setting = BookingSetting.create!(
      user: users(:oneU),
      timezone: "UTC",
      weekly_hours: { "1" => [ { "start" => "09:00", "end" => "11:00" } ] },
      duration_options: [ 60 ],
      default_duration: 60,
      minimum_notice_hours: 48,
      buffer_minutes: 0
    )
    busy = FakeBusyIntervals.new([ [ Time.utc(2026, 9, 22, 9), Time.utc(2026, 9, 22, 10) ] ])
    finder = AvailableSlotFinder.new(setting, busy_intervals: busy, now: Time.utc(2026, 9, 21, 6))

    assert finder.free?(starts_at: Time.utc(2026, 9, 21, 14), duration_minutes: 60)
    assert_not finder.free?(starts_at: Time.utc(2026, 9, 22, 9), duration_minutes: 60)
  end
end
