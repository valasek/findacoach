require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get clients_url
    assert_response :success
  end

  test "should get new" do
    get new_client_url
    assert_response :success
  end

  test "should create client" do
    assert_difference("Client.count") do
      # avoid Client validation errors: ["Email has already been taken", "Phone has already been taken"]
      post clients_url, params: { client: { archived: @client.archived, user_id: @client.user_id, coaching_goal: @client.coaching_goal, company: @client.company, email: "email99@gmail.com", hours_delivered: @client.hours_delivered, hours_ordered: @client.hours_ordered, name: @client.name, phone: "123456789", position: @client.position } }
    end

    assert_redirected_to clients_url # (Client.last)
  end

  test "should show client" do
    get client_url(@client)
    assert_response :success
  end

  test "should get edit" do
    get edit_client_url(@client)
    assert_response :success
  end

  test "should update client" do
    # commented out setting user_id: @client.user_id
    patch client_url(@client), params: { client: { archived: @client.archived, coaching_goal: @client.coaching_goal, company: @client.company, email: @client.email, hours_delivered: @client.hours_delivered, hours_ordered: @client.hours_ordered, name: @client.name, phone: @client.phone, position: @client.position } }
    assert_redirected_to client_url(@client)
  end

  test "should destroy client" do
    assert_difference("Client.count", -1) do
      delete client_url(@client)
    end

    assert_redirected_to clients_url
  end
end
