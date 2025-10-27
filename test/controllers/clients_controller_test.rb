require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:oneC)
    @user = users(:oneU)
  end

  # test "should get index" do
  #   sign_in @user
  #   get clients_url
  #   assert_response :success
  # end

  # test "should get new" do
  #   sign_in @user
  #   get new_client_url
  #   assert_response :success
  # end

  # test "should create client" do
  #   assert_difference("Client.count") do
  #     post clients_url, params: { client: { email: @client.email, name: @client.name, notes: @client.notes, phone: @client.phone, user_id: @client.user_id } }
  #   end

  #   assert_redirected_to client_url(Client.last)
  # end

  # test "should show client" do
  #   sign_in @user
  #   get client_url(@client)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   sign_in @user
  #   get edit_client_url(@client)
  #   assert_response :success
  # end

  # test "should update client" do
  #   sign_in @user
  #   patch client_url(@client), params: { client: { email: @client.email, name: @client.name, notes: @client.notes, phone: @client.phone, user_id: @client.user_id } }
  #   assert_redirected_to clients_path
  # end

  # test "should destroy client" do
  #   sign_in @user
  #   assert_difference("Client.count", -1) do
  #     delete client_url(@client)
  #   end

  #   assert_redirected_to clients_url
  # end
end
