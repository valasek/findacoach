require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "contact details are unique per coach" do
    first = Client.create!(user: users(:oneU), name: "First Client", email: "SHARED@example.com")
    other_coach = Client.new(user: users(:twoU), name: "Second Client", email: "shared@example.com")
    duplicate = Client.new(user: users(:oneU), name: "Duplicate Client", email: "shared@example.com")

    assert_equal "shared@example.com", first.email
    assert other_coach.valid?
    assert_not duplicate.valid?
  end
end
