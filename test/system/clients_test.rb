require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
  setup do
    @client = clients(:one)
    @user = users(:one)
    sign_in @user
  end

  test "visiting the index" do
    visit clients_url
    assert_selector "h1", text: "Clients"
  end

  test "should create client" do
    visit clients_url
    click_on "New client"

    check "Archived" if @client.archived
    # fill_in "User", with: @client.user_id
    fill_in "Coaching goal", with: @client.coaching_goal
    fill_in "Company", with: @client.company
    fill_in "Email", with: @client.email
    fill_in "Hours delivered", with: @client.hours_delivered
    fill_in "Hours ordered", with: @client.hours_ordered
    fill_in "Name", with: @client.name
    fill_in "Phone", with: @client.phone
    fill_in "Position", with: @client.position
    click_on "Create Client"

    assert_text "Client was successfully created"
    click_on "Back"
  end

  test "should update Client" do
    visit client_url(@client)
    click_on "Edit this client", match: :first

    check "Archived" if @client.archived
    # fill_in "User", with: @client.user_id
    fill_in "Coaching goal", with: @client.coaching_goal
    fill_in "Company", with: @client.company
    fill_in "Email", with: @client.email
    fill_in "Hours delivered", with: @client.hours_delivered
    fill_in "Hours ordered", with: @client.hours_ordered
    fill_in "Name", with: @client.name
    fill_in "Phone", with: @client.phone
    fill_in "Position", with: @client.position
    click_on "Update Client"

    assert_text "Client was successfully updated"
    click_on "Back"
  end

  test "should destroy Client" do
    visit client_url(@client)
    click_on "Destroy this client", match: :first

    assert_text "Client was successfully destroyed"
  end
end
