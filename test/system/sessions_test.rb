require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup do
    @session = sessions(:oneS)
  end

  test "visiting the index" do
    visit sessions_url
    assert_selector "h1", text: "Sessions"
  end

  test "should create session" do
    visit sessions_url
    click_on "New session"

    fill_in "Client", with: @session.client_id
    fill_in "Date", with: @session.date
    fill_in "Duration", with: @session.duration
    check "Group" if @session.group
    fill_in "Group size", with: @session.group_size
    fill_in "Notes", with: @session.notes
    check "Paid" if @session.paid
    click_on "Create Session"

    assert_text "Session was successfully created"
    click_on "Back"
  end

  test "should update Session" do
    visit session_url(@session)
    click_on "Edit this session", match: :first

    fill_in "Client", with: @session.client_id
    fill_in "Date", with: @session.date
    fill_in "Duration", with: @session.duration
    check "Group" if @session.group
    fill_in "Group size", with: @session.group_size
    fill_in "Notes", with: @session.notes
    check "Paid" if @session.paid
    click_on "Update Session"

    assert_text "Session was successfully updated"
    click_on "Back"
  end

  test "should destroy Session" do
    visit session_url(@session)
    accept_confirm { click_on "Destroy this session", match: :first }

    assert_text "Session was successfully removed"
  end
end
