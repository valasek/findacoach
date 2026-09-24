require "test_helper"

class IcsCalendarFetcherTest < ActiveSupport::TestCase
  test "rejects private network calendar URLs" do
    error = assert_raises(IcsCalendarFetcher::Error) do
      IcsCalendarFetcher.new("https://127.0.0.1/calendar.ics").call
    end

    assert_equal "Calendar could not be reached safely", error.message
  end
end
