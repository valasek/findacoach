require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "accepts quarter-hour durations" do
    session = Session.new(
      client: clients(:oneC),
      service: services(:one),
      date: Date.current,
      duration: 0.25,
      paid: false
    )

    assert session.valid?
  end
end
