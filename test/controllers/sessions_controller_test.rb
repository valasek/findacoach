require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:oneU)
    @client = clients(:oneC)
    @session = sessions(:oneS)
  end

  test "should get select_client" do
    sign_in @user
    get start_session_url
    assert_response :success
    assert_select "a[href=?]", new_client_session_path(@client, source: "select_client")
  end

  test "should filter clients on select_client by query" do
    sign_in @user
    get start_session_url, params: { query: "no-such-client" }
    assert_response :success
    assert_select "a[href=?]", new_client_session_path(@client, source: "select_client"), count: 0
  end

  test "should not list other users clients on select_client" do
    sign_in @user
    get start_session_url
    assert_response :success
    assert_select "a[href=?]", new_client_session_path(clients(:twoC), source: "select_client"), count: 0
  end

  test "should redirect select_client when not signed in" do
    get start_session_url
    assert_redirected_to new_user_session_url
  end

  # test "should get index" do
  #   sign_in @user
  #   get client_sessions_url(@client)
  #   assert_response :success
  # end

  # test "should redirect index when not signed in" do
  #   get sessions_url
  #   assert_redirected_to new_user_session_url
  # end

  # test "should get new" do
  #   sign_in @user
  #   get new_client_session_url(@client)
  #   assert_response :success
  # end

  # test "should redirect new when not signed in" do
  #   get new_client_session_url(@client)
  #   assert_redirected_to new_user_session_url
  # end

  # test "should create session" do
  #   sign_in @user
  #   assert_difference("Session.count") do
  #     post sessions_url, params: { client_id: @client.id, session: { date: Date.today, duration: 60, group: false, group_size: nil, notes: "Test session", paid: false } }
  #   end
  #   assert_redirected_to client_path(@client)
  # end

  # test "should not create session without client" do
  #   sign_in @user
  #   assert_no_difference("Session.count") do
  #     post sessions_url, params: { session: { date: Date.today, duration: 60, group: false, group_size: nil, notes: "No client", paid: false } }
  #   end
  #   assert_response :unprocessable_entity
  # end

  # test "should show session" do
  #   sign_in @user
  #   get client_session_url(@client, @session)
  #   assert_response :success
  # end

  # test "should redirect show when not signed in" do
  #   get client_session_url(@client, @session)
  #   assert_redirected_to new_user_session_url
  # end

  # test "should get edit" do
  #   sign_in @user
  #   get edit_client_session_url(@client, @session)
  #   assert_response :success
  # end

  # test "should update session" do
  #   sign_in @user
  #   patch client_session_url(@client, @session), params: { session: { notes: "Updated notes" } }
  #   assert_redirected_to client_path(@client)
  #   @session.reload
  #   assert_equal "Updated notes", @session.notes
  # end

  # test "should destroy session" do
  #   sign_in @user
  #   assert_difference("Session.count", -1) do
  #     delete client_session_url(@client, @session)
  #   end
  #   assert_redirected_to client_path(@client)
  # end

  # test "should redirect edit when not signed in" do
  #   get edit_client_session_url(@client, @session)
  #   assert_redirected_to new_user_session_url
  # end

  # test "should redirect update when not signed in" do
  #   patch client_session_url(@client, @session), params: { session: { notes: "Should not update" } }
  #   assert_redirected_to new_user_session_url
  # end

  # test "should redirect destroy when not signed in" do
  #   assert_no_difference("Session.count") do
  #     delete client_session_url(@client, @session)
  #   end
  #   assert_redirected_to new_user_session_url
  # end
end
