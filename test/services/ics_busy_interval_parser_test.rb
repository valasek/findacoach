require "test_helper"

class IcsBusyIntervalParserTest < ActiveSupport::TestCase
  test "expands recurrence and excludes transparent and excepted events" do
    body = <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Find a Coach Test//EN
      BEGIN:VEVENT
      UID:weekly@example.com
      DTSTART:20260921T100000Z
      DTEND:20260921T110000Z
      RRULE:FREQ=DAILY;COUNT=3
      EXDATE:20260922T100000Z
      END:VEVENT
      BEGIN:VEVENT
      UID:transparent@example.com
      DTSTART:20260921T120000Z
      DTEND:20260921T130000Z
      TRANSP:TRANSPARENT
      END:VEVENT
      END:VCALENDAR
    ICS

    intervals = IcsBusyIntervalParser.new(
      body,
      window_start: Time.utc(2026, 9, 21),
      window_end: Time.utc(2026, 9, 25),
      coach_timezone: "Europe/Bratislava"
    ).call

    assert_equal [ Time.utc(2026, 9, 21, 10), Time.utc(2026, 9, 23, 10) ], intervals.map(&:first)
    assert intervals.all? { |starts_at, ends_at| ends_at - starts_at == 1.hour }
  end

  test "converts an Outlook timezone event to UTC" do
    body = <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Microsoft Corporation//Outlook 16.0 MIMEDIR//EN
      BEGIN:VEVENT
      UID:outlook@example.com
      DTSTART;TZID=Europe/Prague:20261005T090000
      DTEND;TZID=Europe/Prague:20261005T100000
      END:VEVENT
      END:VCALENDAR
    ICS

    intervals = IcsBusyIntervalParser.new(
      body,
      window_start: Time.utc(2026, 10, 5),
      window_end: Time.utc(2026, 10, 6),
      coach_timezone: "Europe/Prague"
    ).call

    assert_equal Time.utc(2026, 10, 5, 7), intervals.first.first
    assert_equal Time.utc(2026, 10, 5, 8), intervals.first.last
  end

  test "accepts an array-valued UTC timezone from Google Calendar" do
    body = <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Google Inc//Google Calendar 70.9054//EN
      BEGIN:VEVENT
      UID:google-utc@example.com
      DTSTART;TZID=UTC:20260924T090000
      DTEND;TZID=UTC:20260924T100000
      END:VEVENT
      END:VCALENDAR
    ICS

    intervals = IcsBusyIntervalParser.new(
      body,
      window_start: Time.utc(2026, 9, 24),
      window_end: Time.utc(2026, 9, 25),
      coach_timezone: "UTC"
    ).call

    assert_equal [ [ Time.utc(2026, 9, 24, 9), Time.utc(2026, 9, 24, 10) ] ], intervals
  end
end
